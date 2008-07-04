From: Henrique de Moraes Holschuh <hmh@hmh.eng.br>
Subject: Re: [bug?] tg3: Failed to load firmware "tigon/tg3_tso.bin"
Date: Fri, 4 Jul 2008 20:58:39 -0300
Message-ID: <20080704235839.GA5649__46809.7488781952$1215217026$gmane$org@khazad-dum.debian.net>
References: <486D6DDB.4010205@infradead.org> <87ej6armez.fsf@basil.nowhere.org> <1215177044.10393.743.camel@pmac.infradead.org> <486E2260.5050503@garzik.org> <1215178035.10393.763.camel@pmac.infradead.org> <20080704141014.GA23215@mit.edu> <s5habgxloct.wl%tiwai@suse.de> <486E3622.1000900@suse.de> <1215182557.10393.808.camel@pmac.infradead.org> <20080704231322.GA4410@dspnet.fr.eu.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Olivier Galibert <galibert@pobox.com>,
	David Woodhouse <dwmw2@infradead.org>,
	Hannes Reinecke <hare@suse.de>, Takashi Iwai <tiwai@suse.de>,
	Theodore Tso <tytso@mit.edu>, Jeff Garzik <
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5.smtp.messagingengine.com ([66.111.4.29]:35735 "EHLO
	out5.smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751146AbYGEAPw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jul 2008 20:15:52 -0400
Content-Disposition: inline
In-Reply-To: <20080704231322.GA4410@dspnet.fr.eu.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 05 Jul 2008, Olivier Galibert wrote:
> On Fri, Jul 04, 2008 at 03:42:37PM +0100, David Woodhouse wrote:
> > It doesn't yet; that patch is in linux-next. The firmware is shipped as
> > part of the kernel source tree, and you currently need to run 'make
> > firmware_install' to put it in /lib/firmware, although we're looking at
> > making that easier because apparently having to run 'make
> > firmware_install' is too hard...
> 
> Won't that break multiple kernel installs on any binary packaging
> system that cares about file collisions?  Multiple kernel rpms
> providing the same /lib/firmware files would break things wouldn't
> they ?

Correct.

We will probably need per-kernel directories, exactly like what is done for
modules.  And since there are (now) both kernel-version-specific, and
non-kernel-version-specific firmware, this means the firmware loader should
look first on the version-specific directory (say, /lib/firmware/$(uname
-r)/), then if not found, on the general directory (/lib/firmware).

Nothing too dificult to pull off, but something that needs to be done before
this entire thing gets deployed on unsuspecting users.  It is bad enough
that it created such a commotion when deployed on unsuspecting developers...

-- 
  "One disk to rule them all, One disk to find them. One disk to bring
  them all and in the darkness grind them. In the Land of Redmond
  where the shadows lie." -- The Silicon Valley Tarot
  Henrique Holschuh
