From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Fw: [Bug 15974] New: kernel panic when squid in bridge mode
Date: Fri, 14 May 2010 08:24:26 -0700
Message-ID: <20100514082426.274be129@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Bart De Schuymer <bdschuym@pandora.be>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:54697 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752469Ab0ENPYr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 May 2010 11:24:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Fri, 14 May 2010 08:52:07 GMT
From: bugzilla-daemon@bugzilla.kernel.org
To: shemminger@linux-foundation.org
Subject: [Bug 15974] New: kernel panic when squid in bridge mode


https://bugzilla.kernel.org/show_bug.cgi?id=15974

           Summary: kernel panic when squid in bridge mode
           Product: Networking
           Version: 2.5
    Kernel Version: 2.6.30.5
          Platform: All
        OS/Version: Linux
              Tree: Mainline
            Status: NEW
          Severity: high
          Priority: P1
         Component: IPV4
        AssignedTo: shemminger@linux-foundation.org
        ReportedBy: senthilkumaar2021@gmail.com
        Regression: No


Hi we are using squid tproxy in bridge mode .The kernel version used is
2.6.30.5 once in 10-15 hours we are getting kernel panic message in he screen
.We are passing traffic of 100Mbps through bridge.The iptables and ebtables are
used for squid

ptables -t mangle -N DIVERT
iptables -t mangle -A DIVERT -j MARK --set-mark 1
iptables -t mangle -A DIVERT -j ACCEPT

iptables -t mangle -A PREROUTING -p tcp -m socket -j DIVERT
iptables -t mangle -A PREROUTING -p tcp --dport 80 -j TPROXY --tproxy-mark
0x1/0x1 --on-port 3129

ebtables -t broute -A BROUTING -i $CLIENT_IFACE -p ipv4 --ip-proto tcp
--ip-dport 80 -j redirect --redirect-target DROP

ebtables -t broute -A BROUTING -i $INET_IFACE -p ipv4 --ip-proto tcp --ip-sport
80 -j redirect --redirect-target DROP 


we have got kernel panic in kernel 2.6.28.5 also

the error is

<ffffffffa03933c2>] ? nf_nat_fn+0x138/0x14e [iptable_nat]
[<ffffffffa0393585>] ? nf_nat_in+0x2f/0x6e [iptable_nat]
[<ffffffffa027edaa>] ? br_nf_pre_routing_finish+0x0/0x2c4 [bridge]
[<ffffffffa027edfa>] br_nf_pre_routing_finish+0x50/0x2c4 [bridge]
[<ffffffffa027edaa>] ? br_nf_pre_routing_finish+0x0/0x2c4 [bridge]
[<ffffffff81339a50>] ? nf_hook_slow+0x68/0xc8
[<ffffffffa027edaa>] ? br_nf_pre_routing_finish+0x0/0x2c4 [bridge]
[<ffffffffa027f616>] br_nf_pre_routing+0x5a8/0x5c7 [bridge]
[<ffffffff813399ab>] nf_iterate+0x48/0x85
[<ffffffffa027a931>] ? br_handle_frame_finish+0x0/0x154 [bridge]
[<ffffffff81339a50>] nf_hook_slow+0x68/0xc8
[<ffffffffa027a931>] ? br_handle_frame_finish+0x0/0x154 [bridge]
[<ffffffffa027ac36>] br_handle_frame+0x1b1/0x1db [bridge]
[<ffffffff8131d54b>] netif_receive_skb+0x316/0x434
[<ffffffff8131dbfb>] napi_gro_receive+0x6e/0x83
[<ffffffffa0125bfe>] e1000_receive_skb+0x5c/0x65 [e1000e]
[<ffffffffa0125de8>] e1000_clean_rx_irq+0x1e1/0x28f [e1000e]
[<ffffffffa012730e>] e1000_clean+0x99/0x24a [e1000e]
[<ffffffff813bcfc5>] ? _spin_unlock_irqrestore+0x2c/0x43
[<ffffffff8131ba62>] net_rx_action+0xb8/0x1b4
[<ffffffff8104ed43>] __do_softirq+0x99/0x152
[<ffffffff8101284c>] call_softirq+0x1c/0x30
[<ffffffff81013a02>] do_softirq+0x52/0xb9
[<ffffffff8104e969>] irq_exit+0x53/0x8d
[<ffffffff81013d1a>] do_IRQ+0x135/0x157
[<ffffffff81011f93>] ret_from_intr+0x0/0x2e
<EOI> [<ffffffff81017e20>] ? mwait_idle+0x9e/0xc7
[<ffffffff81017e17>] ? mwait_idle+0x95/0xc7
[<ffffffff813bfd20>] ? atomic_notifier_call_chain+0x13/0x15
[<ffffffff810102f4>] ? enter_idle+0x27/0x29


Please help me in fixing the issue

-- 
Configure bugmail: https://bugzilla.kernel.org/userprefs.cgi?tab=email
------- You are receiving this mail because: -------
You are the assignee for the bug.


-- 
