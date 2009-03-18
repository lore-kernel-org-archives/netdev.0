From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [net-next PATCH 1/2] igbvf: add new driver to support 82576 virtual
 functions
Date: Wed, 18 Mar 2009 08:22:46 -0700
Message-ID: <49C111C6.2010905@intel.com>
References: <20090311020928.23138.20790.stgit@lost.foo-projects.org>	<20090310222154.4bc8c12c.akpm@linux-foundation.org>	<49C03C80.5020203@intel.com> <20090317180826.8f3c596b.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"greg@kroah.com" <greg@kroah.com>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"Zhao, Yu" <yu.zhao@intel.com>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:47300 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752191AbZCRPWt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Mar 2009 11:22:49 -0400
In-Reply-To: <20090317180826.8f3c596b.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Morton wrote:
> On Tue, 17 Mar 2009 17:12:48 -0700 Alexander Duyck <alexander.h.duyck@intel.com> wrote:
> 
>> Thanks for all the comments.  I tried to incorporate most of them into 
>> the igbvf driver and also ended up porting some over to our other 
>> drivers, specifically igb since the igbvf driver copies much of the code.
>>
>> I have added my comments inline below.
>>
>> Thanks,
>>
>> Alex
>>
>> Andrew Morton wrote:
>>> On Tue, 10 Mar 2009 19:09:28 -0700 Jeff Kirsher <jeffrey.t.kirsher@intel.com> wrote:
>>>
>>>> From: Alexander Duyck <alexander.h.duyck@intel.com>
>>>>
>>>> This adds an igbvf driver to handle virtual functions provided
>>>> by the igb driver.
>>> The drive-by reader is now wondering what a "virtual function" is.
> 
> ^^ this comment was missed.
> 
> I was indirectly asking for an overview (preferably in the changelog) of
> what the whole patch actually does.

Sorry, while I missed the comment in my response I had gotten to 
addressing it in the next version.  I updated it to more thoroughly 
describe what the VF driver is doing.  I also included instructions on 
how to enable the VFs from the PF so that they can be tested.

>>>> +static int igbvf_set_ringparam(struct net_device *netdev,
>>>> +                               struct ethtool_ringparam *ring)
>>>> +{
>>>> +     struct igbvf_adapter *adapter = netdev_priv(netdev);
>>>> +     struct igbvf_ring *tx_ring, *tx_old;
>>>> +     struct igbvf_ring *rx_ring, *rx_old;
>>>> +     int err;
>>>> +
>>>> +     if ((ring->rx_mini_pending) || (ring->rx_jumbo_pending))
>>>> +             return -EINVAL;
>>>> +
>>>> +     while (test_and_set_bit(__IGBVF_RESETTING, &adapter->state))
>>>> +             msleep(1);
>>> No timeout needed here?  Interrupts might not be working, for example..
>> This bit isn't set in interrupt context.  This is always used out of 
>> interrupt context and is just to prevent multiple setting changes at the 
>> same time.
> 
> Oh.  Can't use plain old mutex_lock()?

We have one or two spots that actually check to see if the bit is set 
and just report a warning instead of actually waiting on the bit to clear.

