From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch v1, kernel version 3.2.1] Source mode for macvlan
 interaface
Date: Mon, 23 Jan 2012 18:08:45 +0100
Message-ID: <1327338525.2525.37.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <22013455.801327321838477.JavaMail.root@5-MeO-DMT.ynet.sk>
	 <1327327879.2525.21.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <CAGsizzLK4HNT+Y3FP_f96LxgROx5BoL-J5iaBj7+Ok5-973+gw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: =?UTF-8?Q?=C5=A0tefan?= Gula <steweg@ynet.sk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAGsizzLK4HNT+Y3FP_f96LxgROx5BoL-J5iaBj7+Ok5-973+gw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le lundi 23 janvier 2012 =C3=A0 15:44 +0100, =C5=A0tefan Gula a =C3=A9c=
rit :
> 2012/1/23 Eric Dumazet <eric.dumazet@gmail.com>:

> >> +static void macvlan_hash_del_sources(struct macvlan_source_list *=
list,
> >> +                                     bool sync)
> >> +{
> >> +     hlist_del_rcu(&list->hlist);
> >> +     kfree_rcu(list, rcu);
> >> +     if (sync)
> >> +             synchronize_rcu();
> >> +}
> >> +
> >
> > Please explain why are you using synchronize_rcu() here, as there m=
ust
> > be a good reason, but I missed it.
> I though so, but I was not sure whether that should be removed or not
> so I rather leave it there as I followed the original code structure
> of macvlan driver. So should I remove it?

If you use kfree_rcu(), its a call_rcu() : A grace period will be
respected before the object freeing, so you dont need the
synchronize_rcu() at all.
