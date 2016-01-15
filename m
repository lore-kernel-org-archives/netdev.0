From: Florian Westphal <fw@strlen.de>
Subject: Re: nf_conntrack_h323: Fix locking in process_urq
Date: Fri, 15 Jan 2016 23:42:33 +0100
Message-ID: <20160115224233.GA20767@breakpoint.cc>
References: <1452894918.4622.3.camel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Sebastian =?iso-8859-15?Q?P=F6hn?= <sebastian.poehn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:40090 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752789AbcAOWmf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jan 2016 17:42:35 -0500
Content-Disposition: inline
In-Reply-To: <1452894918.4622.3.camel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sebastian P=F6hn <sebastian.poehn@gmail.com> wrote:

[ CC netfilter-devel ]

> nf_ct_remove_expectations has to be called under nf_conntrack_expect_=
lock

But nf_ct_remove_expectations grabs that lock?

Added in:

commit ca7433df3a672efc88e08222cfa4b3aa965ca324
Author: Jesper Dangaard Brouer <brouer@redhat.com>
netfilter: conntrack: seperate expect locking from nf_conntrack_lock

> diff --git a/net/netfilter/nf_conntrack_h323_main.c b/net/netfilter/n=
f_conntrack_h323_main.c
> index 9511af0..d477375 100644
> --- a/net/netfilter/nf_conntrack_h323_main.c
> +++ b/net/netfilter/nf_conntrack_h323_main.c
> @@ -1518,7 +1518,9 @@ static int process_urq(struct sk_buff *skb, str=
uct nf_conn *ct,
> =A0=A0=A0=A0=A0=A0=A0=A0}
> =A0
> =A0=A0=A0=A0=A0=A0=A0=A0/* Clear old expect */
> +=A0=A0=A0=A0=A0=A0=A0spin_lock_bh(&nf_conntrack_expect_lock);
> =A0=A0=A0=A0=A0=A0=A0=A0nf_ct_remove_expectations(ct);

=2E.. so I'd expect deadlock.
