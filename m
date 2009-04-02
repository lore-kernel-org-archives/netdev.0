From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [netfilter bug] BUG: using smp_processor_id() in preemptible
 [00000000] code: ssh/9115, caller is ipt_do_table+0xc8/0x559
Date: Thu, 02 Apr 2009 22:18:14 +0200
Message-ID: <49D51D86.9030906@cosmosbay.com>
References: <20090402200128.GA21805@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Rusty Russell <rusty@rustcorp.com.au>, coreteam@netfilter.org
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netfilter-owner@vger.kernel.org>
In-Reply-To: <20090402200128.GA21805@elte.hu>
Sender: netfilter-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ingo Molnar a =E9crit :
> Not sure whether this bug has been reported before (a quick subject=20
> search on netdev and lkml suggests that it's not):
>=20
> i switched over -tip to latest -git an hour ago (it was on a v2.6.29=20
> base before that), and one of my testboxes started emitting lots of=20
> these warnings:


Hi Ingo

David put into its tree fix for that a few hours ago

commit fa9a86ddc8ecd2830a5e773facc250f110300ae7

(netfilter: iptables: lock free counters) forgot to disable BH
in arpt_do_table(), ipt_do_table() and  ip6t_do_table()

Use rcu_read_lock_bh() instead of rcu_read_lock() cures the problem.

Reported-and-bisected-by: Roman Mindalev <r000n@r000n.net>
Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
Acked-by: Patrick McHardy <kaber@trash.net>
Acked-by: Stephen Hemminger <shemminger@vyatta.com>
Signed-off-by: David S. Miller <davem@davemloft.net>


Should be pushed to Linus in next round

Thank you

http://git2.kernel.org/?p=3Dlinux/kernel/git/davem/net-2.6.git;a=3Dcomm=
itdiff;h=3Dfa9a86ddc8ecd2830a5e773facc250f110300ae7


