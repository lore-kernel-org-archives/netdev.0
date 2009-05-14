From: Michael Riepe <michael.riepe@googlemail.com>
Subject: Re: 2.6.27.19 + 28.7: network timeouts for r8169 and 8139too
Date: Thu, 14 May 2009 21:42:59 +0200
Message-ID: <4A0C7443.1010000@googlemail.com>
References: <200903041828.49972.m.bueker@berlin.de> <1242001754.4093.12.camel@obelisk.thedillows.org> <200905112248.44868.mb@bu3sch.de> <200905112310.08534.mb@bu3sch.de> <1242077392.3716.15.camel@lap75545.ornl.gov> <4A09DC3E.2080807@googlemail.com> <1242268709.4979.7.camel@obelisk.thedillows.org> <4A0C6504.8000704@googlemail.com> <1242328457.32579.12.camel@lap75545.ornl.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Michael Buesch <mb@bu3sch.de>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Rui Santos <rsantos@grupopie.com>,
	=?ISO-8859-15?Q?Michael_B=FCker?= <m.bueker@berlin.de>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Dillow <dave@thedillows.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f158.google.com ([209.85.220.158]:62666 "EHLO
	mail-fx0-f158.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751225AbZENTnC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 May 2009 15:43:02 -0400
In-Reply-To: <1242328457.32579.12.camel@lap75545.ornl.gov>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



David Dillow wrote:
> On Thu, 2009-05-14 at 20:37 +0200, Michael Riepe wrote:
> 
>>David Dillow wrote:
>>
>>>On Tue, 2009-05-12 at 22:29 +0200, Michael Riepe wrote:
>>>The patched driver runs on 2.6.27 and survives my 5 minutes 'dd
>>>if=/dev/zero bs=1024k | nc target 9000' test which usually dies in less
>>>than 90 seconds on 2.6.28+.
>>
>>Not on my system:
> 
> 
>>This happened less than half a minute after the transfer had started.
>>And it's going to happen earlier if I increase the load. With four
>>connections to two other hosts, the transmission usually pauses after
>>less than ten seconds. Sometimes it lasts for only two or three seconds.
> 
> 
> Bummer, but a good data point; thanks for testing.
> 
> I added some code to print the irq status when it hangs, and it shows
> 0x0085, which is RxOK | TxOK | TxDescUnavail, which makes me think we've
> lost an MSI-edge interrupt somehow. You being able to reproduce it on
> 2.6.27 where I cannot leads me to think that the bisection down into the
> genirq tree just changed the timing and made it easier to hit after it
> was merged.

Maybe. With a single connection, 2.6.27 with the 2.6.29 driver seemed to
be a little more stable (i.e. the transfers lasted a little longer under
low and medium loads) than 2.6.29, but that's nothing I could actually
quantify.

> So, I suppose a good review of the IRQ handling of r8169.c is in order,
> though my SATA disks (AHCI w/ MSI irqs) also seem to have similar issues
> with delays, though that is entirely unqualified and unmeasured.

Hey, MSI isn't bad in general. The e1000e driver on my Lenovo T60 uses
it as well, and it's as reliable as a rock.

-- 
Michael "Tired" Riepe <michael.riepe@googlemail.com>
X-Tired: Each morning I get up I die a little
