From: Peter Moody <pmoody@google.com>
Subject: Re: [PATCH v2 0/2] RFC, aiding pid/network correlation
Date: Sat, 02 Aug 2014 18:34:00 -0700
Message-ID: <r3nzjfmjr07.fsf@perdido.sfo.corp.google.com>
References: <1406856100-21674-1-git-send-email-pmoody@google.com>
	<87y4v876bs.fsf@synack.fr> <r3noaw4m8g6.fsf@perdido.sfo.corp.google.com>
	<lrhr02$ncj$1@ger.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-security-module@vger.kernel.org, netdev@vger.kernel.org
To: Alex Elsayed <eternaleye@gmail.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <lrhr02$ncj$1@ger.gmane.org> (Alex Elsayed's message of "Fri\, 01
	Aug 2014 21\:55\:27 -0700")
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hey Alex,

On Fri, Aug 01 2014 at 21:55, Alex Elsayed wrote:
> Out of curiosity, have you looked at Tomoyo much at all? In particular, it:
>
> 1.) Keeps a tree all the way back to init
> 2.) Has network event hooks (see footnote [1])
> 3.) Has an interactive API for managing policy violations (tomoyo-queryd[2] 
> uses it)
> 4.) Is in mainline already.

I have looked at tomoyo before. There were a couple of things that kept
it from being suitable for our needs:

The big one is that since the process tree is used to check policy, it's
kept in-kernel and I'm primarily interested in having these events be
easily exportable.  IIRC (at least when I last looked), it wasn't
possible to stream the events as they happened. tomoyo-queryd looks like
it gets me real-time policy violations, but I don't have any policy
per-se. I'm just trying to monitor processes and network activity.

We also already use apparmor so switching to a different LSM was a
non-trivial task (admittedly this is now an issue for hone too, but hone
wasn't an LSM initially).

> The combination is actually sufficient to implement what you want for Hone 
> _today_ as far as I can tell, and there's even the out-of-tree AKARI variant 
> if you want to use it together with another LSM.
>
> There's also Caitsith[3] (also from Tetsuo Handa), which might be even 
> better suited but is not in mainline yet.

I'm not familiar with AKARI or Caitsith. I'll take a look.

 Cheers,
 peter
