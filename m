From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next] macvlan: Propagate lowerdev MTU changes
Date: Tue, 13 May 2014 14:29:06 +0200
Message-ID: <20140513122906.GD2910@minipsycho.orion>
References: <5371BE1F.7030508@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f54.google.com ([74.125.83.54]:39691 "EHLO
	mail-ee0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759395AbaEMM3L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2014 08:29:11 -0400
Received: by mail-ee0-f54.google.com with SMTP id b57so357295eek.41
        for <netdev@vger.kernel.org>; Tue, 13 May 2014 05:29:09 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <5371BE1F.7030508@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, May 13, 2014 at 08:39:27AM CEST, dingtianhong@huawei.com wrote:
>When the physical MTU changes we should ensure that all existing MACVLAN
>dev MTU do not exceed the new lowerdev MTU. This patch adds that
>propagation.
>
>Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
>---
> drivers/net/macvlan.c | 7 +++++++
> 1 file changed, 7 insertions(+)
>
>diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
>index f0118d1..e03707d 100644
>--- a/drivers/net/macvlan.c
>+++ b/drivers/net/macvlan.c
>@@ -1091,6 +1091,13 @@ static int macvlan_device_event(struct notifier_block *unused,
> 			netdev_update_features(vlan->dev);
> 		}
> 		break;
>+	case NETDEV_CHANGEMTU:
>+		list_for_each_entry(vlan, &port->vlans, list) {
>+			if (vlan->dev->mtu <= dev->mtu)
>+				continue;
>+			dev_set_mtu(vlan->dev, dev->mtu);
>+		}
>+		break;
> 	case NETDEV_UNREGISTER:
> 		/* twiddle thumbs on netns device moves */
> 		if (dev->reg_state != NETREG_UNREGISTERING)
>-- 
>1.8.0

Reviewed-by: Jiri Pirko <jiri@resnulli.us>
