From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Patch net-next v3] net: fix some RCU warnings in various places
Date: Fri, 15 Feb 2013 22:23:24 -0800
Message-ID: <1360995804.19353.55.camel@edumazet-glaptop>
References: <1360993680-7992-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jiri Pirko <jiri@resnulli.us>,
	Vlad Yasevich <vyasevic@redhat.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:52141 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751181Ab3BPGX2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Feb 2013 01:23:28 -0500
Received: by mail-pa0-f50.google.com with SMTP id fa11so2027263pad.37
        for <netdev@vger.kernel.org>; Fri, 15 Feb 2013 22:23:27 -0800 (PST)
In-Reply-To: <1360993680-7992-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2013-02-16 at 13:48 +0800, Cong Wang wrote:
> From: Cong Wang <amwang@redhat.com>
> 
> This fixes sparse warnings like the one below:

>  static inline void br_netpoll_send_skb(const struct net_bridge_port *p,
> @@ -469,7 +469,7 @@ extern void br_multicast_free_pg(struct rcu_head *head);
>  extern struct net_bridge_port_group *br_multicast_new_port_group(
>  				struct net_bridge_port *port,
>  				struct br_ip *group,
> -				struct net_bridge_port_group *next,
> +				struct net_bridge_port_group __rcu *next,
>  				unsigned char state);
>  extern void br_mdb_init(void);
>  extern void br_mdb_uninit(void);

This part is wrong, please remove the __rcu annotation in function
definition.

To perform " rcu_assign_pointer(p->next, next); ", there is no need to
annotate "next" with __rcu
