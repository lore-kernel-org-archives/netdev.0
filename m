From: Meelis Roos <mroos@linux.ee>
Subject: Re: ipv4_get_l4proto: Frag of proto 17
Date: Sat, 1 Sep 2007 18:04:16 +0300 (EEST)
Message-ID: <Pine.SOC.4.64.0709011803450.14157@math.ut.ee>
References: <Pine.SOC.4.64.0708211355310.24028@math.ut.ee> <46D66D00.7060801@trash.net>
 <Pine.SOC.4.64.0708301557400.9520@math.ut.ee> <46D8F87A.1080604@trash.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org,
	Netfilter Development Mailinglist
	<netfilter-devel@lists.netfilter.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.it.da.ut.ee ([193.40.5.67]:36051 "EHLO smtp2.it.da.ut.ee"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753380AbXIAPFP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 1 Sep 2007 11:05:15 -0400
In-Reply-To: <46D8F87A.1080604@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> I'm guessing that its ICMP errors containing UDP fragments.
> 
> Could you add a WARN_ON(1) to ipv4_get_l4proto() in
> net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c to verify
> this?

Yes, it seems to be an ICMP error:

WARNING: at net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c:93 ipv4_get_l4proto()
 [<c0103447>] show_trace_log_lvl+0x1a/0x2f
 [<c0103f2e>] show_trace+0x12/0x14
 [<c0103f45>] dump_stack+0x15/0x17
 [<f8cc60fc>] ipv4_get_l4proto+0x78/0xc0 [nf_conntrack_ipv4]
 [<f8d14fc4>] nf_ct_get_tuplepr+0x45/0xae [nf_conntrack]
 [<f8cc6777>] icmp_error+0x185/0x1f6 [nf_conntrack_ipv4]
 [<f8d1548f>] nf_conntrack_in+0xc0/0x409 [nf_conntrack]
 [<f8cc6251>] ipv4_conntrack_in+0x11/0x13 [nf_conntrack_ipv4]
 [<c028f16e>] nf_iterate+0x36/0x67
 [<c028f519>] nf_hook_slow+0x57/0xd6
 [<c0294a97>] ip_rcv+0x1d9/0x489
 [<c027a38e>] netif_receive_skb+0x2c9/0x34a
 [<f88ca79d>] rtl8139_poll+0x2a5/0x410 [8139too]
 [<c027bfa4>] net_rx_action+0x56/0xd5
 [<c011af47>] __do_softirq+0x38/0x7a
 [<c01048e5>] do_softirq+0x41/0x91
 =======================
ipv4_get_l4proto: Frag of proto 17

-- 
Meelis Roos (mroos@linux.ee)
