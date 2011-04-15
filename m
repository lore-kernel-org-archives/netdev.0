From: Wei Gu <wei.gu@ericsson.com>
Subject: RE: Low performance Intel 10GE NIC (3.2.10) on 2.6.38 Kernel
Date: Fri, 15 Apr 2011 10:10:54 +0800
Message-ID: <D12839161ADD3A4B8DA63D1A134D084026E4953A04@ESGSCCMS0001.eapac.ericsson.se>
References: <D12839161ADD3A4B8DA63D1A134D084026E48B9BEB@ESGSCCMS0001.eapac.ericsson.se>
	 <1302253651.4409.2.camel@edumazet-laptop>
	 <D12839161ADD3A4B8DA63D1A134D084026E48BA66B@ESGSCCMS0001.eapac.ericsson.se>
	 <1302267400.4409.22.camel@edumazet-laptop>
	 <D12839161ADD3A4B8DA63D1A134D084026E48BA682@ESGSCCMS0001.eapac.ericsson.se>
	 <1302275223.4409.36.camel@edumazet-laptop>
	 <D12839161ADD3A4B8DA63D1A134D084026E48BA6AE@ESGSCCMS0001.eapac.ericsson.se>
	 <1302330998.2656.113.camel@edumazet-laptop>
	 <D12839161ADD3A4B8DA63D1A134D084026E48BA730@ESGSCCMS0001.eapac.ericsson.se>
	 <4DA3151B.4030507@intel.com>
	 <D12839161ADD3A4B8DA63D1A134D084026E4909714@ESGSCCMS0001.eapac.ericsson.se>
	 <1302536577.4605.1.camel@edumazet-laptop>
	 <D12839161ADD3A4B8DA63D1A134D084026E49535F2@ESGSCCMS0001.eapac.ericsson.se>
	 <1302761251.3549.198.camel@edumazet-laptop>
	 <1302762810.3549.233.camel@edumazet-laptop>
	 <D12839161ADD3A4B8DA63D1A134D084026E49536AF@ESGSCCMS0001.eapac.ericsson.se>
	 <4DA723F1.7000901@intel.com>  <1302800202.2035.32.camel@laptop>
 <1302800221.3248.39.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	Mike Galbraith <efault@gmx.de>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw10.se.ericsson.net ([193.180.251.61]:42445 "EHLO
	mailgw10.se.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751956Ab1DOCLB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2011 22:11:01 -0400
In-Reply-To: <1302800221.3248.39.camel@edumazet-laptop>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,
I tried another parameter intel_idle.max_cstate=3D0 with 2.6.35.3
Looks like this setting make the a little better, less rx_error and muc=
h more stable.
However I haven't found this kernel param in the kernel document, but s=
upprise it still works somehow:)

I will check with the HP guys to see if I need to do extra configuratio=
n in BIOS to disable more ACPI related features on DL580.

Thanks
WeiGu

-----Original Message-----
=46rom: Eric Dumazet [mailto:eric.dumazet@gmail.com]
Sent: Friday, April 15, 2011 12:57 AM
To: Peter Zijlstra
Cc: Alexander Duyck; Wei Gu; netdev; Kirsher, Jeffrey T; Mike Galbraith
Subject: Re: Low performance Intel 10GE NIC (3.2.10) on 2.6.38 Kernel

Le jeudi 14 avril 2011 =E0 18:56 +0200, Peter Zijlstra a =E9crit :
> On Thu, 2011-04-14 at 09:42 -0700, Alexander Duyck wrote:
>
> > I'm doing some more digging into this now.  One thought that
> > occurred to me is that if the patch you mention is having some sort
> > of effect this could be a sign of perhaps a kernel timer or schedul=
ing problem.
>
> Right, so the removal of the NO_HZ throttle will allow the CPU to go
> into C states more often, this could result in longer wake-up times
> for IRQs.
>
> We reverted because:
>   - it caused significant battery drain due to not going into C state=
s
>     often enough, and
>   - its a much better idea to implement these things in the idle
>     governor since it already has the job of guestimating the idle
>     duration.
>
> I really can't remember back far enough to even come up with a theory
> of why kernels prior to merging the NO_HZ throttle would not exhibit
> this problem.
>
>
>

Normally, Wei Gu already asked to not use C states.

http://h20000.www2.hp.com/bc/docs/support/SupportManual/c01804533/c0180=
4533.pdf

How can we/he check this ?



