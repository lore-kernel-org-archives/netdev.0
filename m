From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next PATCH v1 08/11] net: rocker: add get flow API operation
Date: Fri, 02 Jan 2015 13:15:33 -0800
Message-ID: <54A70A75.2030001@gmail.com>
References: <20141231194057.31070.5244.stgit@nitbit.x32> <20141231194852.31070.72727.stgit@nitbit.x32> <CAKoUArm4z_i6Su9Q4ODB1QYR_Z098MjT2yN=WR7LbN387AvPsg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: simon.horman@netronome.com, Jamal Hadi Salim <jhs@mojatatu.com>,
	Scott Feldman <sfeldma@gmail.com>,
	David Miller <davem@davemloft.net>,
	Andy Gospodarek <andy@greyhouse.net>,
	Thomas Graf <tgraf@suug.ch>, Netdev <netdev@vger.kernel.org>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>
To: Rami Rosen <roszenrami@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f46.google.com ([209.85.218.46]:38272 "EHLO
	mail-oi0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752120AbbABVPy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jan 2015 16:15:54 -0500
Received: by mail-oi0-f46.google.com with SMTP id a3so10886184oib.5
        for <netdev@vger.kernel.org>; Fri, 02 Jan 2015 13:15:53 -0800 (PST)
In-Reply-To: <CAKoUArm4z_i6Su9Q4ODB1QYR_Z098MjT2yN=WR7LbN387AvPsg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/02/2015 12:46 PM, Rami Rosen wrote:
> Nice work!
>
>
> =D7=91=D7=AA=D7=90=D7=A8=D7=99=D7=9A 31 =D7=91=D7=93=D7=A6=D7=9E 2014
>
>
>  > +static int rocker_get_flows(struct sk_buff *skb, struct net_devic=
e *dev,
>  > +                           int table, int min, int max)
>  > +{
>  > +       struct rocker_port *rocker_port =3D netdev_priv(dev);
>  > +       struct net_flow_flow flow;
>  > +       struct rocker_flow_tbl_entry *entry;
>  > +       struct rocker_group_tbl_entry *group;
>  > +       struct hlist_node *tmp;
>  > +       unsigned long flags;
>  > +       int bkt, err;
>  > +
>  > +       spin_lock_irqsave(&rocker_port->rocker->flow_tbl_lock, fla=
gs);
>  > +       hash_for_each_safe(rocker_port->rocker->flow_tbl,
>  > +                          bkt, tmp, entry, entry) {
>  > +               struct rocker_flow_tbl_key *key =3D &entry->key;
>  > +
>  > +               if (rocker_goto_value(table) !=3D key->tbl_id)
>  > +                       continue;
>  > +
>  > +               flow.table_id =3D table;
>  > +               flow.uid =3D entry->cookie;
>  > +               flow.priority =3D key->priority;
>  > +
>  > +               switch (table) {
>  > +               case ROCKER_FLOW_TABLE_ID_INGRESS_PORT:
>  > +                       err =3D rocker_ig_port_to_flow(key, &flow)=
;
>  > +                       if (err)
>  > +                               return err;
>  > +                       break;
>  > +               case ROCKER_FLOW_TABLE_ID_VLAN:
>  > +                       err =3D rocker_vlan_to_flow(key, &flow);
>  > +                       if (err)
>  > +                               return err;
>  > +                       break;
>  > +               case ROCKER_FLOW_TABLE_ID_TERMINATION_MAC:
>  > +                       err =3D rocker_term_to_flow(key, &flow);
>
> Shouldn't it be here (and in the following 3 case entries) also:
>

Yes, thanks for catching this. I'll update it in v2. Along with the
other fixes for dev_put misses.

=2EJohn


--=20
John Fastabend         Intel Corporation
