From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [RFC net-next 01/14] Add Default
Date: Tue, 19 Jun 2012 12:01:54 -0700
Message-ID: <4FE0CCA2.304@intel.com>
References: <1340118848-30978-1-git-send-email-yuvalmin@broadcom.com> <1340118848-30978-2-git-send-email-yuvalmin@broadcom.com> <4FE0AABE.4070100@intel.com> <1340127678.2486.18.camel@lb-tlvb-eilong.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Yuval Mintz <yuvalmin@broadcom.com>, netdev@vger.kernel.org,
	davem@davemloft.net
To: eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:61334 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750955Ab2FSTBz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Jun 2012 15:01:55 -0400
In-Reply-To: <1340127678.2486.18.camel@lb-tlvb-eilong.il.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/19/2012 10:41 AM, Eilon Greenstein wrote:
> On Tue, 2012-06-19 at 09:37 -0700, Alexander Duyck wrote:
>> On 06/19/2012 08:13 AM, Yuval Mintz wrote:
>>> Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
>>> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
>>> ---
>>>  include/linux/etherdevice.h |    5 ++++-
>>>  1 files changed, 4 insertions(+), 1 deletions(-)
>>>
>>> diff --git a/include/linux/etherdevice.h b/include/linux/etherdevice.h
>>> index 3d406e0..bb1ecaf 100644
>>> --- a/include/linux/etherdevice.h
>>> +++ b/include/linux/etherdevice.h
>>> @@ -44,7 +44,10 @@ extern int eth_mac_addr(struct net_device *dev, void *p);
>>>  extern int eth_change_mtu(struct net_device *dev, int new_mtu);
>>>  extern int eth_validate_addr(struct net_device *dev);
>>>  
>>> -
>>> +/* The maximal number of RSS queues a driver should have unless configured
>>> + * so explicitly.
>>> + */
>>> +#define DEFAULT_MAX_NUM_RSS_QUEUES (8)
>>>  
>>>  extern struct net_device *alloc_etherdev_mqs(int sizeof_priv, unsigned int txqs,
>>>  					    unsigned int rxqs);
>> I'm not a big fan of just having this as a fixed define in the code.  It
>> seems like it would make much more sense to have this in the Kconfig
>> somewhere as a range value if you plan on making this changeable in the
>> future.
> My original suggestion was a kernel command line parameter, but Dave was
> less than enthusiastic. If you will follow the original thread, you can
> probably understand why I decided to adopt Dave's constant approach
> without suggesting Kconfig:
> http://marc.info/?l=linux-netdev&m=133992386010982&w=2
There is a huge difference between a kernel parameter an a kconfig
value.  The main idea behind the kconfig value is that you are going to
have different preferences depending on architectures and such so it
would make much more sense to have the default as a config option.
> However, 8 is not a holy number - I'm open for suggestions.
>
> Thanks,
> Eilon
I'm not sure why you couldn't just limit it to 16.  From what I can tell
that is the largest number that gets used for RSS queues on almost all
the different hardware out there.

As far as the rest of the patches for the Intel drivers go you might be
better off if you understood how we allocate queues on the ixgbe/ixgbevf
drivers.  Usually we have the number of queues determined before we set
the number of vectors so your patches that limited the number of vectors
aren't going to have the effect you desire.  So for example RSS
configuration is currently handled in either ixgbe_set_rss_queues or
ixgbe_set_dcb_queues depending on the mode the driver is in.  You would
be much better off looking there for how to limit the RSS queueing on
the ixgbe adapter.

Thanks,

Alex
