From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: V2.4 policy router operates faster/better than V2.6
Date: Thu, 6 Jan 2005 19:15:48 +0100
Message-ID: <16861.32852.11187.131058@robur.slu.se>
References: <200501031455.26980.jeremy.guthrie@berbee.com>
	<200501051325.40616.jeremy.guthrie@berbee.com>
	<16860.19615.251360.169722@robur.slu.se>
	<200501060926.54588.jeremy.guthrie@berbee.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Robert Olsson <Robert.Olsson@data.slu.se>,
        Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: jeremy.guthrie@berbee.com
In-Reply-To: <200501060926.54588.jeremy.guthrie@berbee.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Jeremy M. Guthrie writes:

 > I still don't see the rt_cache_stat file even under 2.4.28 stock.  See below.

 > ls -la /proc/net/stat/
 > total 0
 > -r--r--r--  1 root root 0 Jan  6 09:22 rt_cache


 rtstat is replaced by lnstat which is in iproute2 package:
 http://developer.osdl.org/dev/iproute2/download/

 (Old version  ftp://robur.slu.se/pub/Linux/net-development/rt_cache_stat/rtstat.c)
 

 > cat /proc/net/softnet_stat
 > 96deb140 0032844e 00012bbb 00000fd8 00000000 00000000 00000000 00000000 
 > 00000dd4
 > 00013dda 00000000 00000000 00000000 00000000 00000000 00000000 00000000 
 > 0000041f


 You only use CPU0 for packet processing. Also it seems you use  the non-NAPI 
 version of e1000.

 > cat /proc/interrupts
 >            CPU0       CPU1
 >   0:     821852    5664906    IO-APIC-edge  timer
 >   1:        484       1247    IO-APIC-edge  keyboard
 >   8:          0          2    IO-APIC-edge  rtc
 >  14:          5         16    IO-APIC-edge  ide0
 >  18: 1928608529       1374   IO-APIC-level  eth3
 >  20:          1  226113098   IO-APIC-level  eth2
 >  27:       7950      34312   IO-APIC-level  eth0


 Traffic is flowing from eth3->eth2 Why all the interrupts on eth2/CPU1? 
 Is traffic most unidirectional?


						--ro
