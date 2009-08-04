From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Kernel oops on setting sky2 interfaces down
Date: Tue, 4 Aug 2009 16:08:05 -0700
Message-ID: <20090804160805.2a63699d@nehalam>
References: <4A65EC3F.4050400@gibraltar.at>
	<20090723102848.00a56ad1@nehalam>
	<4A6D8975.4050000@gibraltar.at>
	<20090727153548.7c0d9f85@nehalam>
	<4A76D036.6090705@gibraltar.at>
	<4A772A1D.1030904@mayrhofer.eu.org>
	<4A77E56B.9030804@gibraltar.at>
	<392fb48f0908040445pc21105bo3182773b76d49596@mail.gmail.com>
	<4A78BC48.4060200@gibraltar.at>
	<4A78BD5F.2030901@mayrhofer.eu.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Mike McCormack <mikem@ring3k.org>, netdev@vger.kernel.org,
	Richard Leitner <leitner@esys.at>
To: Rene Mayrhofer <rene@mayrhofer.eu.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:42840 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753569AbZHDXIK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Aug 2009 19:08:10 -0400
In-Reply-To: <4A78BD5F.2030901@mayrhofer.eu.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 05 Aug 2009 00:59:43 +0200
Rene Mayrhofer <rene@mayrhofer.eu.org> wrote:

> -----BEGIN PGP SIGNED MESSAGE-----
> Hash: SHA1
> 
> Rene Mayrhofer wrote:
> > Nonetheless, the current unmodified version from netdev git solves the
> > oops in sky2. 
> Actually, it doesn't. I managed to run networking restart twice without
> an oops (with the netdev git version of sky2.c), but after generating
> some minor traffic and trying to restart again, I still get this oops:
> 
> [~]# /etc/init.d/networking restart
> Reconfiguring network interfaces...[  844.000236] sky2 0000:01:00.0:
> error interrupt status=0xffffffff
> 
> [  844.007309] sky2 0000:01:00.0: PCI hardware error (0xffff)
> 
> [  844.013657] sky2 0000:01:00.0: PCI Express error (0xffffffff)

There is something about the hardware on your system that causes
the Marvell chip to not be present on the bus after the steps taken
in sky2_down.  Is there something unique about how it is wired to
the PCI express bus?

The sky2 driver has to handle the rare case of dual port board, so
in sky2_down in only shuts off part of the chip. Driver turns off the PHY
and stops receiver/transmitter.  It could be the power control bits
on your hardware turn off more than just the PHY. Or perhaps,
most systems have a low power input to keep chip alive for Wake On
Lan and that isn't present on your system. 

Maybe an option to not power down phy would be the simplest fix.

-- 
