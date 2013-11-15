From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH net v2 1/2] macvlan: introduce macvlan_dev_real_dev()
 helper function
Date: Thu, 14 Nov 2013 21:43:23 -0500
Message-ID: <52858A4B.7000902@gmail.com>
References: <cover.1384436410.git.mkubecek@suse.cz> <b4ca4f2204f0ffb0bd7f959192462944a8d846a4.1384436410.git.mkubecek@suse.cz> <5284E637.5060805@gmail.com> <20131114155756.GA4161@lion.mk-sys.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	John Fastabend <john.r.fastabend@intel.com>
To: Michal Kubecek <mkubecek@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f172.google.com ([209.85.216.172]:65176 "EHLO
	mail-qc0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755516Ab3KOCn0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Nov 2013 21:43:26 -0500
Received: by mail-qc0-f172.google.com with SMTP id q4so1570161qcx.3
        for <netdev@vger.kernel.org>; Thu, 14 Nov 2013 18:43:26 -0800 (PST)
In-Reply-To: <20131114155756.GA4161@lion.mk-sys.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/14/2013 10:57 AM, Michal Kubecek wrote:
> On Thu, Nov 14, 2013 at 10:03:19AM -0500, Vlad Yasevich wrote:
>> On 11/14/2013 09:00 AM, Michal Kubecek wrote:
>>> +#if IS_ENABLED(CONFIG_MACVLAN)
>>> +static inline struct net_device *
>>> +macvlan_dev_real_dev(const struct net_device *dev)
>>> +{
>>> +	struct macvlan_dev *macvlan = netdev_priv(dev);
>>> +
>>> +	return macvlan->lowerdev;
>>> +}
>>> +#else
>>> +static inline struct net_device *
>>> +macvlan_dev_real_dev(const struct net_device *dev)
>>> +{
>>> +	return NULL;
>>> +}
>>> +#endif
>>> +
>>
>> You may want to do the same here as was done for
>> vlan_dev_real_dev(). This function is not intended to be called
>> blindly and should always
>> be called after netif_is_macvlan().
>
> I'm not sure. It makes sense from the developer point of view: if we
> find an inconsistency which must be caused by a bug in kernel code, do
> panic so that the bug is found and fixed as soon as possible. However,
> I remember a discussion where the point was that BUG() and BUG_ON()
> should only be used if there is no way to recover. From this point of
> view, WARN or WARN_ONCE might be better choice - but I'm not strictly
> opposed to BUG().
>
>                                                         Michal Kubecek
>

If someone blindly calls macvlan_dev_real_dev() and macvlan module is 
enabled, but there is no macvlan device, you are going to get garbage 
and crash.  So crashing if module is disabled for the same case seems
perfectly reasonable.

-vlad
