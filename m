From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: 2.6.38-rc3-git1: Reported regressions 2.6.36 -> 2.6.37
Date: Thu, 3 Feb 2011 14:19:31 -0800
Message-ID: <AANLkTin=YcecPX1AOpihPVJO3UOfrcjf0MFTu55dpEUy@mail.gmail.com>
References: <e9vOd5LzdBK.A.dyD.h6eSNB@chimera> <AANLkTikELiGS+fM5WguZS=Fo-sSXmej1UnKWqCFmnE0k@mail.gmail.com>
 <s5haaid3xos.wl%tiwai@suse.de> <201102032009.17100.rjw@sisk.pl>
 <AANLkTi=suS1VDL=6EtT0D2=0c1DWwxdwZBBv=-BySNX-@mail.gmail.com> <AANLkTi=7EOih=fY5FCvhQbewSc=3a49cYVaKJRWM+-3d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>, Takashi Iwai <tiwai@suse.de>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Maciej Rutecki <maciej.rutecki@gmail.com>,
	Florian Mickler <florian@mickler.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kernel Testers List <kernel-testers@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux ACPI <linux-acpi@vger.kernel.org>,
	Linux PM List <linux-pm@lists.linux-foundation.org>,
	Linux SCSI List <linux-scsi@vger.kernel.org>,
	Linux Wireless List <linux-wireless@vger.kernel.org>,
	DRI <dri-devel@lists.freedesktop.org>
To: Carlos Mafra <crmafra2@gmail.com>,
	Keith Packard <keithp@keithp.com>,
	Dave Airlie <airlied@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:39151 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751561Ab1BCWUY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Feb 2011 17:20:24 -0500
In-Reply-To: <AANLkTi=7EOih=fY5FCvhQbewSc=3a49cYVaKJRWM+-3d@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 3, 2011 at 2:10 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> Maybe the right thing to do is to set it to 'unknown', something like this.
>
> TOTALLY UNTESTED!

Doing some grepping and "git blame", I found this: commit 032d2a0d068
("drm/i915: Prevent double dpms on") which took a very similar
approach, except it just uses "-1" directly instead of introducing
that DRM_MODE_DPMS_UNKNOWN concept.

So I suspect that my patch is going in the right direction, and
judging by the comments in that commit, we probably should do this
correctly at the dri level rather than have drivers see those stupid
"let's set dpms to the state that it was already in". But that very
much does require that kind of "UNKNOWN" state option.

So maybe we can get that patch tested (and acked if it works)? Carlos, Takashi?

                         Linus
