From: Jan Engelhardt <jengelh@inai.de>
Subject: Re: [ANNOUNCE] iptables 1.4.16.1 release
Date: Mon, 8 Oct 2012 02:14:53 +0200 (CEST)
Message-ID: <alpine.LNX.2.01.1210080141140.2933@nerf07.vanv.qr>
References: <20121007231706.GA7400@1984>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter@vger.kernel.org, netfilter-announce@lists.netfilter.org,
	lwn@lwn.net
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20121007231706.GA7400@1984>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Monday 2012-10-08 01:17, Pablo Neira Ayuso wrote:
>The Netfilter project proudly presents:
>
>        iptables 1.4.16.1
>
>iptables -I INPUT -j ACCEPT
>says:
>iptables: No chain/target/match by that name.
>This also breaks iptables-restore, of course. Jan, you'll have to explain
>me how you have tested this.

This was tested by adding rules with different targets that had both
aliases defined and those without.

 ./iptables/xtables-multi main4 -t raw -N foo
 ./iptables/xtables-multi main4 -t raw -A foo -j NOTRACK
 with kernels that had xt_CT and no xt_CT at all

 ./iptables/xtables-multi main4 -N foo
 ./iptables/xtables-multi main4 -A foo -m state --state NEW
 with kernels that had xt_conntrack.3, and xt_conntrack.3 removed
 (leaving only xt_conntrack.2)

 ./iptables/xtables-multi main4 -t raw -N bar
 ./iptables/xtables-multi main4 -t raw -A bar -j MARK --set-xmark 1
 ./iptables/xtables-multi main4 -t raw -A foo -j bar

plus of course the "standard" (no pun intended) testsuite that we
had so far:

 # ./iptables/xtables-multi restore6 tests/options-most.rules 
 WARNING: --localtz is being replaced by --kerneltz, since "local" is ambiguous.
 Note the kernel timezone has caveats - see manpage for details.

As you spotted, options-most.rules did not include -j <verdict>.

While v1.4.16-1-g2aaa7ec fixes -j verdict, it breaks NOTRACK in all
instances. To reuse a line, "you'll have to explain me how you have
tested this."

A patch to what I think should fly is posted as a reply hereto.
Please give that a spin.
