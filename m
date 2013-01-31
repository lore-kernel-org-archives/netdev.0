From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [PATCH v7 net-next 03/12] bridge: Verify that a vlan is allowed
 to egress on give port
Date: Thu, 31 Jan 2013 21:03:16 +0100
Message-ID: <CAHXqBFLQofoWPN9nfAKc6xumjzO3hu7ue3r=bHYerypAuRW0qw@mail.gmail.com>
References: <1359601979-14942-1-git-send-email-vyasevic@redhat.com> <1359601979-14942-4-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@vyatta.com, bridge@lists.linux-foundation.org,
	davem@davemloft.net, netdev@vger.kernel.org,
	shmulik.ladkani@gmail.com
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f172.google.com ([209.85.214.172]:55306 "EHLO
	mail-ob0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755233Ab3AaUDh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2013 15:03:37 -0500
Received: by mail-ob0-f172.google.com with SMTP id tb18so3317754obb.17
        for <netdev@vger.kernel.org>; Thu, 31 Jan 2013 12:03:36 -0800 (PST)
In-Reply-To: <1359601979-14942-4-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2013/1/31 Vlad Yasevich <vyasevic@redhat.com>:
> When bridge forwards a frame, make sure that a frame is allowed
> to egress on that port.

=46or egress checks it might be better to have per-vlan bitmaps of port=
s
instead. For unicast this doesn't really change anything, but for
broadcast and multicast all ports are checked so reading all bits from
one location is going to be cheaper.

[...]
> -static inline struct net_port_vlans *br_get_vlan_info(struct net_bri=
dge *br)
> +static inline struct net_port_vlans *br_get_vlan_info(
> +                                               const struct net_brid=
ge *br)
>  {
>         return rcu_dereference(br->vlan_info);
>  }
>
> -static inline struct net_port_vlans *nbp_get_vlan_info(struct net_br=
idge_port *p)
> +static inline struct net_port_vlans *nbp_get_vlan_info(
> +                                               const struct net_brid=
ge_port *p)
>  {
>         return rcu_dereference(p->vlan_info);
>  }

Shouldn't this be in patch 1?

Best Regards,
Micha=B3 Miros=B3aw
