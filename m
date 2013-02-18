From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [Patch net-next v5] netpoll: fix some sparse warnings in various
 places
Date: Mon, 18 Feb 2013 18:01:26 +0100
Message-ID: <20130218170126.GA1576@minipsycho.orion>
References: <1361157749-9367-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>,
	Vlad Yasevich <vyasevic@redhat.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f50.google.com ([74.125.83.50]:62843 "EHLO
	mail-ee0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752086Ab3BRRBb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Feb 2013 12:01:31 -0500
Received: by mail-ee0-f50.google.com with SMTP id e51so3166493eek.37
        for <netdev@vger.kernel.org>; Mon, 18 Feb 2013 09:01:30 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1361157749-9367-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Feb 18, 2013 at 04:22:29AM CET, amwang@redhat.com wrote:
>From: Cong Wang <amwang@redhat.com>
>
>This fixes sparse warnings like the one below:
>
>drivers/net/team/team.c:953:25: warning: incorrect type in return expression (different address spaces)
>drivers/net/team/team.c:953:25:    expected struct netpoll_info *
>drivers/net/team/team.c:953:25:    got struct netpoll_info [noderef] <asn:4>*npinfo
>
>and make these functions return bool as suggested by Jiri.
>
>Cc: Eric Dumazet <eric.dumazet@gmail.com>
>Cc: Jiri Pirko <jiri@resnulli.us>
>Cc: Vlad Yasevich <vyasevic@redhat.com>
>Cc: Stephen Hemminger <stephen@networkplumber.org>
>Cc: David S. Miller <davem@davemloft.net>
>Signed-off-by: Cong Wang <amwang@redhat.com>
>
>---
>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>index 94c1534..2263bf2 100644
>--- a/drivers/net/bonding/bond_main.c
>+++ b/drivers/net/bonding/bond_main.c
>@@ -1300,9 +1300,9 @@ static int bond_netpoll_setup(struct net_device *dev, struct netpoll_info *ni, g
> 	return err;
> }
> 
>-static struct netpoll_info *bond_netpoll_info(struct bonding *bond)
>+static bool bond_netpoll_info(struct bonding *bond)
> {
>-	return bond->dev->npinfo;
>+	return rcu_access_pointer(bond->dev->npinfo) != NULL;
                                                    ^^^^^^^^
						    this is not necessary
						    (sorry for nitpick)
