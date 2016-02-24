From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: net: netcp: regarding commit 899077: netcp: try to reduce type confusion in descriptors
Date: Wed, 24 Feb 2016 13:47:02 +0100
Message-ID: <9482605.o2kvoZbYXY@wuerfel>
References: <56CB821E.7040809@ti.com> <2817046.Cys9vdONqu@wuerfel> <56CB9539.9020108@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: "open list:TI NETCP ETHERNET DRIVER" <netdev@vger.kernel.org>
To: Murali Karicheri <m-karicheri2@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.187]:64215 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751305AbcBXMrH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Feb 2016 07:47:07 -0500
In-Reply-To: <56CB9539.9020108@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 22 February 2016 18:09:45 Murali Karicheri wrote:
> On 02/22/2016 05:13 PM, Arnd Bergmann wrote:
> > On Monday 22 February 2016 16:48:14 Murali Karicheri wrote:
> >> Keystone can have SoC configured to be in big endian mode for peripherals and DSP.
> > 
> > I'm not entirely sure what this means
> 
> This means, ARM core can be using LE/BE and rest of the system can be configured through a pin
> (to SOC) to operate in BE/LE. So need to take care of all mixed endian configuration 
> properly. Refer to http://www.ti.com/lit/ds/symlink/tci6636k2h.pdf for more details if interested.

Ah, that is unfortunate. For the moment, let's hope that nobody ever uses that pin,
so we can support both big-endian and little-endian kernels without having
to do any runtime detection of the board settings.

If anyone is misguided enough to flip that configuration pin to the opposite
setting, then we will require extra DT properties to list for each device
what endianess the hardware uses, and check that flag at runtime, which causes
a little extra overhead.

If you are able to provide any feedback to the hardware designers, please
ask them to never do configurable endianess again: it solves no actual
problems but creates endless nightmares if anyone ever uses that.

> > And this is another one of the same sort.
> > 
> > Not my best patch ever obviously, but at least I understand where I went
> > wrong now, and see that it was only me being sloppy in the conversion rather
> > than a more fundamental misdesign.
> > 
> 
> So do you plan to re-spin the patch again with the above change?

I probably won't bother at this point, but if you could send a patch to get back
to my version with your fixes, I'll send an Ack.

	Arnd
