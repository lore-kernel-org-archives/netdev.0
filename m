From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: V2.4 policy router operates faster/better than V2.6
Date: Tue, 11 Jan 2005 17:40:29 +0100
Message-ID: <16868.381.537772.831831@robur.slu.se>
References: <Pine.LNX.4.44.0501071416060.5818-100000@localhost.localdomain>
	<200501071650.56423.jeremy.guthrie@berbee.com>
	<20050107145711.367aa159@dxpl.pdx.osdl.net>
	<200501110917.26621.jeremy.guthrie@berbee.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Stephen Hemminger <shemminger@osdl.org>,
        Jesse Brandeburg <jesse.brandeburg@intel.com>,
        Robert Olsson <Robert.Olsson@data.slu.se>
Return-path: <netdev-bounce@oss.sgi.com>
To: jeremy.guthrie@berbee.com
In-Reply-To: <200501110917.26621.jeremy.guthrie@berbee.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



About the same load as last time 80 kpps forwarded and droprate of ~200 pps 
and 2323 fib lookups/sec. Not so bad for PIII but it maybe tuned better.

Did the e1000 patch cure the problem that interrupts got enabled for 
unidirectional traffic? Ring size? I've never seen any win in system 
performance w. RX rings larger than 256 at least not in lab.

					   --ro

Jeremy M. Guthrie writes:
 > date ; ifconfig eth3 ; cat /proc/net/softnet_stat ; 
 > cat /proc/net/stat/rt_cache ; sleep 60 ; date ; ifconfig eth3 ; 
 > cat /proc/net/softnet_stat ; cat /proc/net/stat/rt_cache
 > 
 > Tue Jan 11 09:12:21 CST 2005
 > eth3      Link encap:Ethernet  HWaddr 00:02:B3:D5:7E:30
 >           inet addr:10.253.0.1  Bcast:10.255.255.255  Mask:255.255.255.0
 >           inet6 addr: fe80::202:b3ff:fed5:7e30/64 Scope:Link
 >           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
 >           RX packets:3519452697 errors:5558592 dropped:5558592 
 > overruns:4011523 frame:0
 >           TX packets:5 errors:0 dropped:0 overruns:0 carrier:0
 >           collisions:0 txqueuelen:1000
 >           RX bytes:497775695 (474.7 Mb)  TX bytes:398 (398.0 b)
 >           Base address:0x22a0 Memory:eff80000-effa0000
 > 
 > f59427dc 150dc67c 00c562ab 000d2659 00000000 00000000 00000000 00000000 
 > 00547b5b
 > 00038622 00000000 00000065 00000000 00000000 00000000 00000000 00000000 
 > 0006804f
 > entries  in_hit in_slow_tot in_no_route in_brd in_martian_dst in_martian_src  
 > out_hit out_slow_tot out_slow_mc  gc_total gc_ignored gc_goal_miss 
 > gc_dst_overflow in_hlist_search out_hlist_search
 > 0000f3c2  aeca1565 272c383d 00000000 00000000 000089a8 00005298 00000002  
 > 001db403 0003054f 00000000 230aa73c 22fe33eb 00000cf0 00000000 b37011dc 
 > 00957c14
 > 0000f3c2  0000b975 00029703 00000000 00000000 000035a5 00000000 00000000  
 > 00000015 00000083 00000002 000038c8 000038a3 00000000 00000000 0012a566 
 > 0000014d
 > 
 > Tue Jan 11 09:13:21 CST 2005
 > eth3      Link encap:Ethernet  HWaddr 00:02:B3:D5:7E:30
 >           inet addr:10.253.0.1  Bcast:10.255.255.255  Mask:255.255.255.0
 >           inet6 addr: fe80::202:b3ff:fed5:7e30/64 Scope:Link
 >           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
 >           RX packets:3524302561 errors:5571396 dropped:5571396 
 > overruns:4022383 frame:0
 >           TX packets:5 errors:0 dropped:0 overruns:0 carrier:0
 >           collisions:0 txqueuelen:1000
 >           RX bytes:3065327250 (2923.3 Mb)  TX bytes:398 (398.0 b)
 >           Base address:0x22a0 Memory:eff80000-effa0000
 > 
 > f5de26f5 150dc67c 00c562b4 000d2659 00000000 00000000 00000000 00000000 
 > 00547ffd
 > 00038632 00000000 00000065 00000000 00000000 00000000 00000000 00000000 
 > 0006807c
 > entries  in_hit in_slow_tot in_no_route in_brd in_martian_dst in_martian_src  
 > out_hit out_slow_tot out_slow_mc  gc_total gc_ignored gc_goal_miss 
 > gc_dst_overflow in_hlist_search out_hlist_search
 > 0000fc1e  af11f07b 272e58d3 00000000 00000000 000089a8 00005298 00000002  
 > 001db571 00030572 00000000 230cc7f1 23005428 00000cf0 00000000 b4b5b529 
 > 009583b9
 > 0000fc1e  0000b977 00029710 00000000 00000000 000035a7 00000000 00000000  
 > 00000015 00000083 00000002 000038ca 000038a5 00000000 00000000 0012a5c8 
 > 0000014d
 > 
 > -- 
 > 
 > --------------------------------------------------
 > Jeremy M. Guthrie        jeremy.guthrie@berbee.com
 > Senior Network Engineer        Phone: 608-298-1061
 > Berbee                           Fax: 608-288-3007
 > 5520 Research Park Drive         NOC: 608-298-1102
 > Madison, WI 53711
