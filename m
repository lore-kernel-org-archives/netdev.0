From: Thomas Habets <thomas@habets.pp.se>
Subject: Re: BUG: IPv6 stops working after a while, needs ip ne del command
 to reset
Date: Tue, 17 Aug 2010 16:09:02 +0200 (CEST)
Message-ID: <alpine.DEB.1.10.1008171547090.21857@red.crap.retrofitta.se>
References: <alpine.DEB.1.10.1008131952470.19570@red.crap.retrofitta.se>  <1281953960.2524.23.camel@edumazet-laptop>  <alpine.DEB.1.10.1008161224510.13728@red.crap.retrofitta.se>  <alpine.DEB.1.10.1008170719180.21857@red.crap.retrofitta.se>
 <1282024802.2487.687.camel@edumazet-laptop>  <alpine.DEB.1.10.1008171053230.21857@red.crap.retrofitta.se> <1282050920.2448.47.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Thomas Habets <thomas@habets.pp.se>, linux-kernel@vger.kernel.org,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1282050920.2448.47.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 17 Aug 2010, Eric Dumazet wrote:
> Can you try : "ifconfig eth0 allmulti"

That didn't help. "ifconfig eth0" and "ip l" shows that allmulti is now 
set, but no other difference. Can't ping router, and router gets no answer 
when pinging ff02::1. No message in dmesg saying allmulti isn't supported 
or anything like that either.

> If you let a "tcpdump" running with -p option, do you receive the packet
> sent to ethernet dest 33:33:ff:5c:00:02 ?

No. Commented tcpdump output below.

> If you can see it with tcpdump, then NIC gave the frame to us.

Seems to be invisible unless I or tcpdump set promisc mode. But when 
promisc mode is set I can immediately see the 33:33:ff:5c:00:02 packet 
(ND solicitation) and I see that Linux is answering it.

Here's a tcpdump from the Linux host. It's slightliy trimmed to fit in
an email, but the full dump is at http://www.habets.pp.se/tmp/ipv6.pcap

$ sudo tcpdump -pnli eth0 -s0 -w ipv6.pcap ip6
[...]

$ tcpdump -nlr ipv6.pcap
2a00:800:752:1::5c:2 > 2a00:800:752:1::5c:1: ICMP6, echo request
2a00:800:752:1::5c:1 > 2a00:800:752:1::5c:2: ICMP6, echo reply
2a00:800:752:1::5c:2 > 2a00:800:752:1::5c:1: ICMP6, echo request
2a00:800:752:1::5c:1 > 2a00:800:752:1::5c:2: ICMP6, echo reply
2a00:800:752:1::5c:2 > 2a00:800:752:1::5c:1: ICMP6, echo request
2a00:800:752:1::5c:1 > 2a00:800:752:1::5c:2: ICMP6, echo reply

[ here I run "clear ipv6 neighbors" on the Cisco router ]

2a00:800:752:1::5c:2 > 2a00:800:752:1::5c:1: ICMP6, echo request
2a00:800:752:1::5c:2 > 2a00:800:752:1::5c:1: ICMP6, echo request
[ ... more repeated echo requests, no reply ... ]

[ here i run "ip l set promisc on eth0" ]

2a00:800:752:1::5c:1 > ff02::1:ff5c:2: ICMP6, neighbor solicitation, who 
has 2a00:800:752:1::5c:2
2a00:800:752:1::5c:2 > 2a00:800:752:1::5c:1: ICMP6,neighbor advertisement,
tgt is 2a00:800:752:1::5c:2
2a00:800:752:1::5c:1 > 2a00:800:752:1::5c:2: ICMP6, echo reply
2a00:800:752:1::5c:2 > 2a00:800:752:1::5c:1: ICMP6, echo request
2a00:800:752:1::5c:1 > 2a00:800:752:1::5c:2: ICMP6, echo reply
2a00:800:752:1::5c:2 > 2a00:800:752:1::5c:1: ICMP6, echo request
2a00:800:752:1::5c:1 > 2a00:800:752:1::5c:2: ICMP6, echo reply

[ here I run "clear ipv6 neigbors" again ]
2a00:800:752:1::5c:2 > 2a00:800:752:1::5c:1: ICMP6, echo request
2a00:800:752:1::5c:2 > 2a00:800:752:1::5c:1: ICMP6, echo request
2a00:800:752:1::5c:2 > 2a00:800:752:1::5c:1: ICMP6, echo request
2a00:800:752:1::5c:2 > 2a00:800:752:1::5c:1: ICMP6, echo request
2a00:800:752:1::5c:2 > 2a00:800:752:1::5c:1: ICMP6, echo request

---------
typedef struct me_s {
   char name[]      = { "Thomas Habets" };
   char email[]     = { "thomas@habets.pp.se" };
   char kernel[]    = { "Linux" };
   char *pgpKey[]   = { "http://www.habets.pp.se/pubkey.txt" };
   char pgp[] = { "A8A3 D1DD 4AE0 8467 7FDE  0945 286A E90A AD48 E854" };
   char coolcmd[]   = { "echo '. ./_&. ./_'>_;. ./_" };
} me_t;
