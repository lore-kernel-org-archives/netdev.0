From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: Route cache performance under stress
Date: Fri, 13 Jun 2003 19:15:48 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <16106.1732.795402.473613@robur.slu.se>
References: <16102.9418.43884.336925@robur.slu.se>
	<20030610.115759.26513736.davem@redhat.com>
	<16103.27039.204333.952703@robur.slu.se>
	<20030612.223818.74754074.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert.Olsson@data.slu.se, ralph+d@istop.com, ralph@istop.com,
   hadi@shell.cyberus.ca, xerox@foonet.net, sim@netnation.com,
   fw@deneb.enyo.de, netdev@oss.sgi.com, linux-net@vger.kernel.org,
   kuznet@ms2.inr.ac.ru
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030612.223818.74754074.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


David S. Miller writes:
 >    From: Robert Olsson <Robert.Olsson@data.slu.se>
 >    Date: Wed, 11 Jun 2003 19:40:47 +0200
 > 
 >    vma      samples  %-age       symbol name
 >    c023c038 107340   33.143      fn_hash_lookup
 > 
 > Ok, let's optimize our datastructures for how we actually
 > use them :-)  Also, fn_zone shrunk by 8 bytes.

Some percent less on our XEON/UP here.

Input rate 2*190 kpps clone_skb=1. dst hash code in.

Without

Iface   MTU Met  RX-OK RX-ERR RX-DRP RX-OVR  TX-OK TX-ERR TX-DRP TX-OVR Flags
eth0   1500   0 2988282 9680382 9680382 7011722     11      0      0      0 BRU
eth1   1500   0     15      0      0      0 2988291      0      0      0 BRU
eth2   1500   0 2988336 9681671 9681671 7011667      3      0      0      0 BRU
eth3   1500   0      2      0      0      0 2988337      0      0      0 BRU

00002100  000005e8 005b2c4a 00000000 00000001 00000000 00000000 00000000  00000000 00000002 00000000 005b1c49 005b1c3c 00000007 00000000 00bd877c 00000002 

With patch

Iface   MTU Met  RX-OK RX-ERR RX-DRP RX-OVR  TX-OK TX-ERR TX-DRP TX-OVR Flags
eth0   1500   0 2877562 9698244 9698244 7122444     11      0      0      0 BRU
eth1   1500   0     13      0      0      0 2819350      0      0      0 BRU
eth2   1500   0 2877512 9693477 9693477 7122492      4      0      0      0 BRU
eth3   1500   0      1      0      0      0 2877511      0      0      0 BRU

00001ec7  0000058e 0057cb3c 00000000 00000000 00000000 00000000 00000000  00000000 00000000 00000000 0057bb37 0057bb2c 00000008 00000000 00b0c4a6 00000000 


Time for a beer now... Still a lot of progress this week. In practice we
never see "dst cache overflow" again.

Cheers. 

						--ro
