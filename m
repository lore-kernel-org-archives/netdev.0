From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH net 1/2] vlan: make vlan_dev_real_dev work over stacked
 vlans
Date: Sat, 3 Aug 2013 22:11:54 +0200
Message-ID: <20130803201154.GC12638@redhat.com>
References: <1375560467-1604-1-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: netdev@vger.kernel.org, davem@davemloft.net, fubar@us.ibm.com,
	jhs@mojatatu.com
To: Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:17248 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752933Ab3HCUMr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 3 Aug 2013 16:12:47 -0400
Content-Disposition: inline
In-Reply-To: <1375560467-1604-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Aug 03, 2013 at 10:07:46PM +0200, Nikolay Aleksandrov wrote:
>From: Nikolay Aleksandrov <Nikolay Aleksandrov nikolay@redhat.com>
>
>Sometimes we might have stacked vlans on top of each other, and we're
>interested in the first non-vlan real device on the path, so transform
>vlan_dev_real_dev to go over the stacked vlans and extract the first
>non-vlan device.
>
>Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>

Signed-off-by: Veaceslav Falico <vfalico@redhat.com>

>---
> net/8021q/vlan_core.c | 7 ++++++-
> 1 file changed, 6 insertions(+), 1 deletion(-)
>
>diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
>index 4a78c4d..6ee48aa 100644
>--- a/net/8021q/vlan_core.c
>+++ b/net/8021q/vlan_core.c
>@@ -91,7 +91,12 @@ EXPORT_SYMBOL(__vlan_find_dev_deep);
>
> struct net_device *vlan_dev_real_dev(const struct net_device *dev)
> {
>-	return vlan_dev_priv(dev)->real_dev;
>+	struct net_device *ret = vlan_dev_priv(dev)->real_dev;
>+
>+	while (is_vlan_dev(ret))
>+		ret = vlan_dev_priv(ret)->real_dev;
>+
>+	return ret;
> }
> EXPORT_SYMBOL(vlan_dev_real_dev);
>
>-- 
>1.8.1.4
>
