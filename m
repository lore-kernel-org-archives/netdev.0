From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [netfilter bug] BUG: using smp_processor_id() in preemptible
	[00000000] code: ssh/9115, caller is ipt_do_table+0xc8/0x559
Date: Thu, 2 Apr 2009 22:22:46 +0200
Message-ID: <20090402202246.GA12191@elte.hu>
References: <20090402200128.GA21805@elte.hu> <49D51D86.9030906@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Rusty Russell <rusty@rustcorp.com.au>, coreteam@netfilter.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:55906 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759490AbZDBUXI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Apr 2009 16:23:08 -0400
Content-Disposition: inline
In-Reply-To: <49D51D86.9030906@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Eric Dumazet <dada1@cosmosbay.com> wrote:

> Ingo Molnar a =E9crit :
> > Not sure whether this bug has been reported before (a quick subject=
=20
> > search on netdev and lkml suggests that it's not):
> >=20
> > i switched over -tip to latest -git an hour ago (it was on a v2.6.2=
9=20
> > base before that), and one of my testboxes started emitting lots of=
=20
> > these warnings:
>=20
>=20
> Hi Ingo
>=20
> David put into its tree fix for that a few hours ago
>=20
> commit fa9a86ddc8ecd2830a5e773facc250f110300ae7
>=20
> (netfilter: iptables: lock free counters) forgot to disable BH
> in arpt_do_table(), ipt_do_table() and  ip6t_do_table()
>=20
> Use rcu_read_lock_bh() instead of rcu_read_lock() cures the problem.
>=20
> Reported-and-bisected-by: Roman Mindalev <r000n@r000n.net>
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
> Acked-by: Patrick McHardy <kaber@trash.net>
> Acked-by: Stephen Hemminger <shemminger@vyatta.com>
> Signed-off-by: David S. Miller <davem@davemloft.net>
>=20
>=20
> Should be pushed to Linus in next round
>=20
> Thank you
>=20
> http://git2.kernel.org/?p=3Dlinux/kernel/git/davem/net-2.6.git;a=3Dco=
mmitdiff;h=3Dfa9a86ddc8ecd2830a5e773facc250f110300ae7

Small request: it's useful to plain-text include such commits in=20
such email replies - if the patch is not too large. http is not very=20
helpful to reply to specifics and it's not very useful when i want=20
toapply it either. I now have to go hunting for the latest tree :)

	Ingo
