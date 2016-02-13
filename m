From: Ido Schimmel <idosch@mellanox.com>
Subject: Re: [PATCH RFC 1/3] net: bridge: log state when setting it
Date: Sat, 13 Feb 2016 22:03:53 +0200
Message-ID: <20160213200353.GA17193@colbert.idosch.org>
References: <1455312860-24666-1-git-send-email-vivien.didelot@savoirfairelinux.com>
 <1455312860-24666-2-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<kernel@savoirfairelinux.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jiri Pirko <jiri@resnulli.us>,
	Scott Feldman <sfeldma@gmail.com>,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db3on0092.outbound.protection.outlook.com ([157.55.234.92]:35616
	"EHLO emea01-db3-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751228AbcBMUEs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Feb 2016 15:04:48 -0500
Content-Disposition: inline
In-Reply-To: <1455312860-24666-2-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Feb 12, 2016 at 11:34:18PM IST, vivien.didelot@savoirfairelinux.com wrote:

Hi Vivien,

>Every call to br_set_state is followed by a call to br_log_state.
>Directly call it within br_set_state instead.
>
>Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
>---

Maybe I'm missing something, but there are other instances of this
pattern throughout the code, so why not convert them as well? See
br_set_port_state() for example.

Thanks.

> net/bridge/br_stp.c | 5 ++---
> 1 file changed, 2 insertions(+), 3 deletions(-)
>
>diff --git a/net/bridge/br_stp.c b/net/bridge/br_stp.c
>index b3cca12..077afca 100644
>--- a/net/bridge/br_stp.c
>+++ b/net/bridge/br_stp.c
>@@ -52,6 +52,8 @@ void br_set_state(struct net_bridge_port *p, unsigned int state)
> 	if (err && err != -EOPNOTSUPP)
> 		br_warn(p->br, "error setting offload STP state on port %u(%s)\n",
> 				(unsigned int) p->port_no, p->dev->name);
>+	else
>+		br_log_state(p);
> }
> 
> /* called under bridge lock */
>@@ -126,7 +128,6 @@ static void br_root_port_block(const struct net_bridge *br,
> 		  (unsigned int) p->port_no, p->dev->name);
> 
> 	br_set_state(p, BR_STATE_LISTENING);
>-	br_log_state(p);
> 	br_ifinfo_notify(RTM_NEWLINK, p);
> 
> 	if (br->forward_delay > 0)
>@@ -407,7 +408,6 @@ static void br_make_blocking(struct net_bridge_port *p)
> 			br_topology_change_detection(p->br);
> 
> 		br_set_state(p, BR_STATE_BLOCKING);
>-		br_log_state(p);
> 		br_ifinfo_notify(RTM_NEWLINK, p);
> 
> 		del_timer(&p->forward_delay_timer);
>@@ -431,7 +431,6 @@ static void br_make_forwarding(struct net_bridge_port *p)
> 	else
> 		br_set_state(p, BR_STATE_LEARNING);
> 
>-	br_log_state(p);
> 	br_ifinfo_notify(RTM_NEWLINK, p);
> 
> 	if (br->forward_delay != 0)
>-- 
>2.7.1
>
