From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH] team: set qdisc_tx_busylock to avoid LOCKDEP splat
Date: Thu, 4 Oct 2012 11:22:55 +0200
Message-ID: <20121004092255.GB6620@minipsycho.orion>
References: <1349342319.16011.30.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Jiri Pirko <jpirko@redhat.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:37855 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750936Ab2JDJXA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Oct 2012 05:23:00 -0400
Received: by mail-bk0-f46.google.com with SMTP id jk13so149538bkc.19
        for <netdev@vger.kernel.org>; Thu, 04 Oct 2012 02:22:59 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1349342319.16011.30.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Oct 04, 2012 at 11:18:39AM CEST, eric.dumazet@gmail.com wrote:
>From: Eric Dumazet <edumazet@google.com>
>
>If a qdisc is installed on a team device, its possible to get
>a lockdep splat under stress, because nested dev_queue_xmit() can
>lock busylock a second time (on a different device, so its a false
>positive)
>
>Avoid this problem using a distinct lock_class_key for team
>devices.
>
>Signed-off-by: Eric Dumazet <edumazet@google.com>
>Cc: Jiri Pirko <jpirko@redhat.com>
>---
> drivers/net/team/team.c |    2 ++
> 1 file changed, 2 insertions(+)
>
>diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
>index 5c7547c..d44cca3 100644
>--- a/drivers/net/team/team.c
>+++ b/drivers/net/team/team.c
>@@ -1315,6 +1315,7 @@ static const struct team_option team_options[] = {
> 
> static struct lock_class_key team_netdev_xmit_lock_key;
> static struct lock_class_key team_netdev_addr_lock_key;
>+static struct lock_class_key team_tx_busylock_key;
> 
> static void team_set_lockdep_class_one(struct net_device *dev,
> 				       struct netdev_queue *txq,
>@@ -1327,6 +1328,7 @@ static void team_set_lockdep_class(struct net_device *dev)
> {
> 	lockdep_set_class(&dev->addr_list_lock, &team_netdev_addr_lock_key);
> 	netdev_for_each_tx_queue(dev, team_set_lockdep_class_one, NULL);
>+	dev->qdisc_tx_busylock = &team_tx_busylock_key;
> }
> 
> static int team_init(struct net_device *dev)
>
>
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html

Thanks Eric.

Acked-by: Jiri Pirko <jiri@resnulli.us>
