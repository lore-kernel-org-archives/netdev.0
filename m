From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2 1/2] macvlan: introduce macvlan_dev_real_dev()
 helper function
Date: Thu, 14 Nov 2013 17:03:58 -0500 (EST)
Message-ID: <20131114.170358.941846928393883945.davem@davemloft.net>
References: <b4ca4f2204f0ffb0bd7f959192462944a8d846a4.1384436410.git.mkubecek@suse.cz>
	<5284E637.5060805@gmail.com>
	<20131114155756.GA4161@lion.mk-sys.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vyasevich@gmail.com, netdev@vger.kernel.org, kaber@trash.net,
	john.r.fastabend@intel.com
To: mkubecek@suse.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53309 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755637Ab3KNWEB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Nov 2013 17:04:01 -0500
In-Reply-To: <20131114155756.GA4161@lion.mk-sys.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michal Kubecek <mkubecek@suse.cz>
Date: Thu, 14 Nov 2013 16:57:57 +0100

> On Thu, Nov 14, 2013 at 10:03:19AM -0500, Vlad Yasevich wrote:
>> On 11/14/2013 09:00 AM, Michal Kubecek wrote:
>> >+#if IS_ENABLED(CONFIG_MACVLAN)
>> >+static inline struct net_device *
>> >+macvlan_dev_real_dev(const struct net_device *dev)
>> >+{
>> >+	struct macvlan_dev *macvlan = netdev_priv(dev);
>> >+
>> >+	return macvlan->lowerdev;
>> >+}
>> >+#else
>> >+static inline struct net_device *
>> >+macvlan_dev_real_dev(const struct net_device *dev)
>> >+{
>> >+	return NULL;
>> >+}
>> >+#endif
>> >+
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

At least for the time being use BUG(), to be consistent with the same
way how VLAN handles this situation.

Thanks.
