From: "Denys Fedoryshchenko" <denys@visp.net.lb>
Subject: Re: e1000 performance issue in 4 simultaneous links
Date: Fri, 11 Jan 2008 19:36:54 +0200
Message-ID: <20080111173654.M91690@visp.net.lb>
References: <1199981839.8931.35.camel@cafe>	 <36D9DB17C6DE9E40B059440DB8D95F5204275B04@orsmsx418.amr.corp.intel.com> <1200068444.9349.20.camel@cafe> <47879DE4.8080603@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=koi8-r
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from usermail.globalproof.net ([194.146.153.18]:48201 "EHLO
	usermail.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757543AbYAKRhK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jan 2008 12:37:10 -0500
Received: from visp.net.lb (localhost [127.0.0.1])
	by usermail.globalproof.net (Postfix) with ESMTP id 905F1BD417
	for <netdev@vger.kernel.org>; Fri, 11 Jan 2008 19:36:54 +0200 (EET)
In-Reply-To: <47879DE4.8080603@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Maybe good idea to use sysstat ?

http://perso.wanadoo.fr/sebastien.godard/

For example:

visp-1 ~ # mpstat -P ALL 1
Linux 2.6.24-rc7-devel (visp-1)         01/11/08

19:27:57     CPU   %user   %nice    %sys %iowait    %irq   %soft  %steal
   %idle    intr/s
19:27:58     all    0.00    0.00    0.00    0.00    0.00    2.51    0.00   
97.49   7707.00
19:27:58       0    0.00    0.00    0.00    0.00    0.00    4.00    0.00   
96.00   1926.00
19:27:58       1    0.00    0.00    0.00    0.00    0.00    1.01    0.00   
98.99   1926.00
19:27:58       2    0.00    0.00    0.00    0.00    0.00    5.00    0.00   
95.00   1927.00
19:27:58       3    0.00    0.00    0.00    0.00    0.00    0.99    0.00   
99.01   1927.00
19:27:58       4    0.00    0.00    0.00    0.00    0.00    0.00    0.00    
0.00      0.00



> >>     
> >>> When I run netperf in just one interface, I get 940.95 * 10^6 bits/sec
> >>> of transfer rate. If I run 4 netperf against 4 different interfaces, I
> >>> get around 720 * 10^6 bits/sec.
> >>>       
> >> I hope this explanation makes sense, but what it comes down to is that
> >> combining hardware round robin balancing with NAPI is a BAD IDEA.  In
> >> general the behavior of hardware round robin balancing is bad and I'm
> >> sure it is causing all sorts of other performance issues that you may
> >> not even be aware of.
> >>     
> > I've made another test removing the ppc IRQ Round Robin scheme, bonded
> > each interface (eth6, eth7, eth16 and eth17) to different CPUs (CPU1,
> > CPU2, CPU3 and CPU4) and I also get around around 720 * 10^6 bits/s in
> > average.
> >
> > Take a look at the interrupt table this time: 
> >
> > io-dolphins:~/leitao # cat /proc/interrupts  | grep eth[1]*[67]
> > 277:         15    1362450         13         14         13         
14         15         18   XICS      Level     eth6
> > 278:         12         13    1348681         19         13         
15         10         11   XICS      Level     eth7
> > 323:         11         18         17    1348426         18         
11         11         13   XICS      Level     eth16
> > 324:         12         16         11         19    1402709         
13         14         11   XICS      Level     eth17
> >
> >
> > I also tried to bound all the 4 interface IRQ to a single CPU (CPU0)
> > using the noirqdistrib boot paramenter, and the performance was a little
> > worse.
> >
> > Rick, 
> >   The 2 interface test that I showed in my first email, was run in two
> > different NIC. Also, I am running netperf with the following command
> > "netperf -H <hostname> -T 0,8" while netserver is running without any
> > argument at all. Also, running vmstat in parallel shows that there is no
> > bottleneck in the CPU. Take a look: 
> >
> > procs -----------memory---------- ---swap-- -----io---- -system-- -----
cpu------
> >  r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy 
id wa st
> >  2  0      0 6714732  16168 227440    0    0     8     2  203   21  0  1 
98  0  0
> >  0  0      0 6715120  16176 227440    0    0     0    28 16234  505  0 16 
83  0  1
> >  0  0      0 6715516  16176 227440    0    0     0     0 16251  518  0 16 
83  0  1
> >  1  0      0 6715252  16176 227440    0    0     0     1 16316  497  0 15 
84  0  1
> >  0  0      0 6716092  16176 227440    0    0     0     0 16300  520  0 16 
83  0  1
> >  0  0      0 6716320  16180 227440    0    0     0     1 16354  486  0 15 
84  0  1
> >  
> >
> >   
> If your machine has 8 cpus, then your vmstat output shows a 
> bottleneck :)
> 
> (100/8 = 12.5), so I guess one of your CPU is full
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


--
Denys Fedoryshchenko
Technical Manager
Virtual ISP S.A.L.

