From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 06/18] rocker: use swdev get/set attr for bridge
 port flags
Date: Mon, 30 Mar 2015 14:01:18 +0200
Message-ID: <20150330120118.GF2045@nanopsycho.orion>
References: <1427704836-8776-1-git-send-email-sfeldma@gmail.com>
 <1427704836-8776-7-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	linux@roeck-us.net, f.fainelli@gmail.com
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f53.google.com ([74.125.82.53]:36089 "EHLO
	mail-wg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751923AbbC3MBV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Mar 2015 08:01:21 -0400
Received: by wgra20 with SMTP id a20so171273623wgr.3
        for <netdev@vger.kernel.org>; Mon, 30 Mar 2015 05:01:20 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1427704836-8776-7-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Mar 30, 2015 at 10:40:24AM CEST, sfeldma@gmail.com wrote:
>From: Scott Feldman <sfeldma@gmail.com>
>
>Signed-off-by: Scott Feldman <sfeldma@gmail.com>
>---
> drivers/net/ethernet/rocker/rocker.c |   10 ++++++++++
> 1 file changed, 10 insertions(+)

I would squash this patch with the previous one.

>
>diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
>index 224f91d..bc4fd33 100644
>--- a/drivers/net/ethernet/rocker/rocker.c
>+++ b/drivers/net/ethernet/rocker/rocker.c
>@@ -4230,6 +4230,9 @@ static int rocker_port_attr_get(struct net_device *dev, struct swdev_attr *attr)
> 		attr->ppid.id_len = sizeof(rocker->hw.id);
> 		memcpy(&attr->ppid.id, &rocker->hw.id, attr->ppid.id_len);
> 		break;
>+	case SWDEV_ATTR_PORT_BRIDGE_FLAGS:
>+		attr->brport_flags = rocker_port->brport_flags;
>+		break;
> 	default:
> 		return -EOPNOTSUPP;
> 	}
>@@ -4240,12 +4243,19 @@ static int rocker_port_attr_get(struct net_device *dev, struct swdev_attr *attr)
> static int rocker_port_attr_set(struct net_device *dev, struct swdev_attr *attr)
> {
> 	struct rocker_port *rocker_port = netdev_priv(dev);
>+	unsigned long orig_flags;
> 	int err = 0;
> 
> 	switch (attr->attr) {
> 	case SWDEV_ATTR_PORT_STP_STATE:
> 		err = rocker_port_stp_update(rocker_port, attr->stp_state);
> 		break;
>+	case SWDEV_ATTR_PORT_BRIDGE_FLAGS:
>+		orig_flags = rocker_port->brport_flags;
>+		rocker_port->brport_flags = attr->brport_flags;
>+		if ((orig_flags ^ rocker_port->brport_flags) & BR_LEARNING)
>+			err = rocker_port_set_learning(rocker_port);
>+		break;
> 	default:
> 		err = -EOPNOTSUPP;
> 		break;
>-- 
>1.7.10.4
>
