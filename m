From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: Route cache performance under stress
Date: Tue, 10 Jun 2003 15:41:09 +0200
Sender: linux-net-owner@vger.kernel.org
Message-ID: <16101.57333.369129.622540@robur.slu.se>
References: <20030609221911.GF11509@netnation.com>
	<008001c32eda$56760830$4a00000a@badass>
	<20030609.160547.41648991.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@shell.cyberus.ca, sim@netnation.com, xerox@foonet.net,
	fw@deneb.enyo.de, netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030609.160547.41648991.davem@redhat.com>
List-Id: netdev.vger.kernel.org


First run...
 
Worst senario 1 dst/pkt w. 64 byte pkts. 2*10 Million packets injected.
eth0, eth2. Input rate 2*190 kpps clone_skb=1. Routing table of 123946 
routes. UP. NAPI gives fairmess between both DoS attackers. :-) But more 
testing to be done. 


   plain   w. DaveM patch
----------------------------------
      72        114 kpps throughput
30271883   12246290 hash misses (second last in my rt_cache_stat)


58% better... and it can be further improved. 



Iface   MTU Met  RX-OK RX-ERR RX-DRP RX-OVR  TX-OK TX-ERR TX-DRP TX-OVR Flags
eth0   1500   0 1964858 9793618 9793618 8035147     16      0      0      0 BRU
eth1   1500   0     19      0      0      0 1887577      0      0      0 BRU
eth2   1500   0 1964698 9793419 9793419 8035305      3      0      0      0 BRU
eth3   1500   0      1      0      0      0 1886904      0      0      0 BRU
/proc/net/rt_cache_stat
000004ba  00000e27 003be7ba 00000000 00000000 00000000 00000000 00000000  00000001 00000001 00000000 003869c1 00360b4d 00025dcb 00025dca 01cde98b 00000000 


With DaveM hash-list limit patch.

Input rate 2*190 kpps clone_skb=1
Iface   MTU Met  RX-OK RX-ERR RX-DRP RX-OVR  TX-OK TX-ERR TX-DRP TX-OVR Flags
eth0   1500   0 2990462 9680257 9680257 7009542     12      0      0      0 BRU
eth1   1500   0     12      0      0      0 2990467      0      0      0 BRU
eth2   1500   0 2990460 9673421 9673421 7009544      4      0      0      0 BRU
eth3   1500   0      1      0      0      0 2990459      0      0      0 BRU
/proc/net/rt_cache_stat
00000000  00000607 005b3cfb 00000000 00000000 00000000 00000000 00000000  00000000 00000002 00000000 005b2cfa 005b2ced 00000008 00000000 00badd12 00000003 


Cheers.
							--ro
