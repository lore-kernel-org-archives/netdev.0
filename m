From: Arkadiusz Miskiewicz <arekm@maven.pl>
Subject: Re: ~3 hours old git tree: Virtual device lo asks to queue packet!
Date: Thu, 19 Jul 2007 13:52:52 +0200
Message-ID: <200707191352.52707.arekm@maven.pl>
References: <200707182218.13548.arekm@maven.pl> <469F2E14.9050200@trash.net> <469F38BE.4030401@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.carme.maven.pl ([193.239.45.138]:55658 "EHLO
	main.carme.maven.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753796AbXGSLxB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2007 07:53:01 -0400
In-Reply-To: <469F38BE.4030401@trash.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 19 of July 2007, Patrick McHardy wrote:
> Patrick McHardy wrote:
> > Arkadiusz Miskiewicz wrote:
> >>>>CONFIG_NETDEVICES_MULTIQUEUE=3Dy
> >>>
> >>>Does it go away if you disable this option?
> >>
> >>Yes, it goes away after disabling this.
> >
> > I don't see a bug in the code itself, maybe the queue_mapping point=
s
> > to an invalid subqueue. Could you please try this patch and post th=
e
> > output?
>
> OK I see what the problem is. The loopback device is statically
> allocated, so it doesn't have any room for the subqueues reserved.
>
> The easiest fix would be to use egress_subqueue[1] in struct
> net_device, but I think that may cause warnings with newer gccs
> when using a constant index that is > 0. OTOH using constant
> indices doesn't seem to make much sense for the subqueue array.
>
> Arkadiusz, does this patch fix the problem?

It fixes the problem for me.

--=20
Arkadiusz Mi=B6kiewicz        PLD/Linux Team
arekm / maven.pl            http://ftp.pld-linux.org/
