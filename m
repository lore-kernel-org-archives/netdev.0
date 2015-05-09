From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v6 17/23] switchdev: remove unused
 switchdev_port_bridge_dellink
Date: Sat, 9 May 2015 20:54:18 +0200
Message-ID: <20150509185418.GF2290@nanopsycho>
References: <1431193225-807-1-git-send-email-sfeldma@gmail.com>
 <1431193225-807-18-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	linux@roeck-us.net, f.fainelli@gmail.com, andrew@lunn.ch,
	simon.horman@netronome.com, joe@perches.com,
	sridhar.samudrala@intel.com, ronen.arad@intel.com
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f54.google.com ([74.125.82.54]:35331 "EHLO
	mail-wg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751303AbbEISyY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 May 2015 14:54:24 -0400
Received: by wgyo15 with SMTP id o15so97425919wgy.2
        for <netdev@vger.kernel.org>; Sat, 09 May 2015 11:54:23 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1431193225-807-18-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sat, May 09, 2015 at 07:40:19PM CEST, sfeldma@gmail.com wrote:
>From: Scott Feldman <sfeldma@gmail.com>
>
>Now we can remove old wrappers for dellink.
>
>Signed-off-by: Scott Feldman <sfeldma@gmail.com>
>---
> include/net/switchdev.h   |   15 ---------------
> net/bridge/br_netlink.c   |   11 +----------
> net/switchdev/switchdev.c |   30 ------------------------------
> 3 files changed, 1 insertion(+), 55 deletions(-)
>

...

>diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
>index e9b9435..6b67ed3 100644
>--- a/net/bridge/br_netlink.c
>+++ b/net/bridge/br_netlink.c
>@@ -639,7 +639,7 @@ int br_dellink(struct net_device *dev, struct nlmsghdr *nlh, u16 flags)
> {
> 	struct nlattr *afspec;
> 	struct net_bridge_port *p;
>-	int err = 0, ret_offload = 0;
>+	int err = 0;
> 
> 	afspec = nlmsg_find_attr(nlh, sizeof(struct ifinfomsg), IFLA_AF_SPEC);
> 	if (!afspec)
>@@ -658,15 +658,6 @@ int br_dellink(struct net_device *dev, struct nlmsghdr *nlh, u16 flags)
> 		 */
> 		br_ifinfo_notify(RTM_NEWLINK, p);
> 
>-	if (p && !(flags & BRIDGE_FLAGS_SELF)) {
>-		/* del bridge attributes in hardware
>-		 */
>-		ret_offload = switchdev_port_bridge_dellink(dev, nlh, flags);
>-		if (ret_offload && ret_offload != -EOPNOTSUPP)
>-			br_warn(p->br, "error deleting attrs on port %u (%s)\n",
>-				(unsigned int)p->port_no, p->dev->name);
>-	}
>-

You should put this into a separate patch as you did for set part.
