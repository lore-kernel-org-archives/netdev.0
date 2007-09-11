From: David Acker <dacker@roinet.com>
Subject: Re: [PATCH] Fix e100 on systems that have cache incoherent DMA
Date: Tue, 11 Sep 2007 16:54:59 -0400
Message-ID: <46E700A3.5010000@roinet.com>
References: <20070831205430.7209E46C20E@localhost> <46E17CD7.8080605@intel.com> <46E1B75C.6090208@roinet.com> <46E1DDC5.8040202@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Kok, Auke" <auke-jan.h.kok@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Milton Miller <miltonm@bga.com>, netdev@vger.kernel.org,
	e1000-devel@lists.sourceforge.net,
	Scott Feldman <sfeldma@pobox.com>
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-72-92-88-10.phlapa.fios.verizon.net ([72.92.88.10]:52715
	"EHLO smtp.roinet.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964903AbXIKUyz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Sep 2007 16:54:55 -0400
In-Reply-To: <46E1DDC5.8040202@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> David Acker wrote:
>> Let me know if there is any other information I can provide you.  I 
>> will look through the code to see what could be going on with your 
>> machine.  I will also look into reproducing these results with a newer 
>> kernel.  This may be tricky since compulab's patches are pretty stale 
>> and don't always apply easily.
> 
> 
> pktgen outputs for the various cases modified/unmodified[/others?] would 
> be nice, if you have a spot of time.
> 
>     Jeff

I am not familiar with pktgen but I seem to have it working for a simple test.
I edited the 1-1 example from ftp://robur.slu.se/pub/Linux/net-development/pktgen-testing/examples/ .  The results with 
and without the patch are below.  Let me know if you want any other tests run.  I obtained a PCI to miniPCI adapter that 
will let me test my miniPCI based e100s on my main dev box.  I will work on reproducing Intel's results tomorrow as time 
permits.  I am also still trying to get time to work on a recent kernel merge.  Not a lot changed in the 100 since 
2.6.18.4 except a flip from readX/writeX to ioreadX/iowriteX.

-Ack

cm-debian:/tmp# ./pktgen.conf-1-1
Removing all devices
Adding eth0
Setting max_before_softirq 10000
Configuring /proc/net/pktgen/eth0
Running... ctrl^C to stop
Done

Here are the results on 2.6.18.4 with the patch I submitted on my embedded system.

cm-debian:/tmp# cat /proc/net/pktgen/eth0
Params: count 10000000  min_pkt_size: 60  max_pkt_size: 60
      frags: 0  delay: 0  clone_skb: 1000000  ifname: eth0
      flows: 0 flowlen: 0
      dst_min: 192.168.1.40  dst_max:
      src_min:   src_max:
      src_mac: 00:09:30:FF:F2:F6  dst_mac: 00:19:B9:0B:45:8E
      udp_src_min: 9  udp_src_max: 9  udp_dst_min: 9  udp_dst_max: 9
      src_mac_count: 0  dst_mac_count: 0
      Flags:
Current:
      pkts-sofar: 10000000  errors: 0
      started: 14852031282115us  stopped: 14852181463422us idle: 918us
      seq_num: 10000011  cur_dst_mac_offset: 0  cur_src_mac_offset: 0
      cur_saddr: 0x2901a8c0  cur_daddr: 0x2801a8c0
      cur_udp_dst: 9  cur_udp_src: 9
      flows: 0
Result: OK: 150181307(c150180389+d918) usec, 10000000 (60byte,0frags)
   66586pps 31Mb/sec (31961280bps) errors: 0

and here are the results without the patch:

cm-debian:/tmp# cat /proc/net/pktgen/eth0
Params: count 10000000  min_pkt_size: 60  max_pkt_size: 60
      frags: 0  delay: 0  clone_skb: 1000000  ifname: eth0
      flows: 0 flowlen: 0
      dst_min: 192.168.1.40  dst_max:
      src_min:   src_max:
      src_mac: 00:09:30:FF:F2:F6  dst_mac: 00:19:B9:0B:45:8E
      udp_src_min: 9  udp_src_max: 9  udp_dst_min: 9  udp_dst_max: 9
      src_mac_count: 0  dst_mac_count: 0
      Flags:
Current:
      pkts-sofar: 10000000  errors: 0
      started: 14864204332576us  stopped: 14864355451225us idle: 1431us
      seq_num: 10000011  cur_dst_mac_offset: 0  cur_src_mac_offset: 0
      cur_saddr: 0x2901a8c0  cur_daddr: 0x2801a8c0
      cur_udp_dst: 9  cur_udp_src: 9
      flows: 0
Result: OK: 151118649(c151117218+d1431) usec, 10000000 (60byte,0frags)
   66173pps 31Mb/sec (31763040bps) errors: 0


