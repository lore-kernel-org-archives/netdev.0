From: Hannes Payer <hpayer@cosy.sbg.ac.at>
Subject: linux ipv6 multicast kernel implementation
Date: Tue, 24 May 2005 14:11:45 +0200 (CEST)
Message-ID: <Pine.LNX.4.61.0505241408160.4148@drache.cosy.sbg.ac.at>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Dear oss team,
last week i tryed to ask Alan Cox something about the data link layer
imlplementation in the linux kernel. He gave me your email address and 
therefore i forward you this email and hope, that you can help me.


forwarded message:
Dear Alan Cox,
we are trying to get ipv6 protocol independent multicast working on linux 
routers. We used the ipv6 multicast forwarding patch and the pim6sd daemon of 
Michael Hoerdt (http://clarinet.u-strasbg.fr/~hoerdt/linux_ipv6_mforwarding/, 
http://clarinet.u-strasbg.fr/~hoerdt/pim6sd_linux/). The ipv6 multicast kernel 
implementation is based on the existing ipv4 code and therefore we thought that 
you are the right contact person :-)
The ipv6 patch does not work well and we already found some bugs, we were able 
to correct.
We are not sure about one problem:
When the kernel receives a pim register packet, it decapsulates the packet and 
loops the multicast packet back on the register interface (netif_rx(skb) in 
pim6_rcv() pim6.c). Before the packet is looped back, the kernel sets skb->dst 
= NULL;
Therefore in ip6_input.c ip6_rcv_finish() looks up the unicast routing table 
and gets a matching entry. After that the kernel tries to forward the multicast 
packet, but stops at ip6_mr_forward() in ip6mr.c. The comparison 
vif6_table[vif].dev != skb->dev is true und therefore the packet is droped. 
(The lookup always returns dubios interfaces. It should return in our case the 
registry interface)
Our question: Why should we lookup the unicast routing table in this case? 
Would it satisfy to look up the multicast forwarding cache, where a correct 
entry exists - created by the pim6sd daemon? Would it be a problem if we 
override the lookup result with the regvif device after the lookup in this 
case?

I hope you understand the explanation of our problem.
Thank you for your answer.

Yours faithfully,
Hannes Payer
