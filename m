From: Breno Leitao <leitao@linux.vnet.ibm.com>
Subject: Re: e1000 performance issue in 4 simultaneous links
Date: Thu, 10 Jan 2008 15:31:31 -0200
Message-ID: <1199986291.8931.62.camel@cafe>
References: <1199981839.8931.35.camel@cafe>
	 <20080110163626.GJ3544@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from igw1.br.ibm.com ([32.104.18.24]:35965 "EHLO igw1.br.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755535AbYAJRbd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Jan 2008 12:31:33 -0500
Received: from mailhub3.br.ibm.com (mailhub3 [9.18.232.110])
	by igw1.br.ibm.com (Postfix) with ESMTP id 90CFF32C10F
	for <netdev@vger.kernel.org>; Thu, 10 Jan 2008 15:10:44 -0200 (BRDT)
Received: from d24av01.br.ibm.com (d24av01.br.ibm.com [9.18.232.46])
	by mailhub3.br.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m0AHVVFM4505760
	for <netdev@vger.kernel.org>; Thu, 10 Jan 2008 15:31:31 -0200
Received: from d24av01.br.ibm.com (loopback [127.0.0.1])
	by d24av01.br.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m0AHVUQB030308
	for <netdev@vger.kernel.org>; Thu, 10 Jan 2008 15:31:31 -0200
In-Reply-To: <20080110163626.GJ3544@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2008-01-10 at 16:36 +0000, Ben Hutchings wrote:
> > When I run netperf in just one interface, I get 940.95 * 10^6 bits/sec
> > of transfer rate. If I run 4 netperf against 4 different interfaces, I
> > get around 720 * 10^6 bits/sec.
> <snip>
> 
> I take it that's the average for individual interfaces, not the
> aggregate?
Right, each of these results are for individual interfaces. Otherwise,
we'd have a huge problem. :-)

> This can be mitigated by interrupt moderation and NAPI
> polling, jumbo frames (MTU >1500) and/or Large Receive Offload (LRO).
> I don't think e1000 hardware does LRO, but the driver could presumably
> be changed use Linux's software LRO.
Without using these "features" and keeping the MTU as 1500, do you think
we could get a better performance than this one?

I also tried to increase my interface MTU to 9000, but I am afraid that
netperf only transmits packets with less than 1500. Still investigating.

> single CPU this can become a bottleneck.  Does the test system have
> multiple CPUs?  Are IRQs for the multiple NICs balanced across
> multiple CPUs?
Yes, this machine has 8 ppc 1.9Ghz CPUs. And the IRQs are balanced
across the CPUs, as I see in /proc/interrupts: 

# cat /proc/interrupts 
           CPU0       CPU1       CPU2       CPU3       CPU4       CPU5       CPU6       CPU7       
 16:        940        760       1047        904        993        777        975        813   XICS      Level     IPI
 18:          4          3          4          1          3          6          8          3   XICS      Level     hvc_console
 19:          0          0          0          0          0          0          0          0   XICS      Level     RAS_EPOW
273:      10728      10850      10937      10833      10884      10788      10868      10776   XICS      Level     eth4
275:          0          0          0          0          0          0          0          0   XICS      Level     ehci_hcd:usb1, ohci_hcd:usb2, ohci_hcd:usb3
277:     234933     230275     229770     234048     235906     229858     229975     233859   XICS      Level     eth6
278:     266225     267606     262844     265985     268789     266869     263110     267422   XICS      Level     eth7
279:        893        919        857        909        867        917        894        881   XICS      Level     eth0
305:     439246     439117     438495     436072     438053     440111     438973     438951   XICS      Level     eth0 Neterion Xframe II 10GbE network adapter
321:       3268       3088       3143       3113       3305       2982       3326       3084   XICS      Level     ipr
323:     268030     273207     269710     271338     270306     273258     270872     273281   XICS      Level     eth16
324:     215012     221102     219494     216732     216531     220460     219718     218654   XICS      Level     eth17
325:       7103       3580       7246       3475       7132       3394       7258       3435   XICS      Level     pata_pdc2027x
BAD:       4216

Thanks,

-- 
Breno Leitao <leitao@linux.vnet.ibm.com>

