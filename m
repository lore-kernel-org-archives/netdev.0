From: "Robert P. J. Day" <rpjday@mindspring.com>
Subject: Re: [PATCH] IP_VS should depend on EXPERIMENTAL ?
Date: Fri, 20 Jul 2007 09:04:20 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0707200846170.13750@localhost.localdomain>
References: <46A0A01A.7030403@googlemail.com> <Pine.LNX.4.64.0707200753300.10966@localhost.localdomain>
 <46A0A7C2.3090006@googlemail.com> <Pine.LNX.4.64.0707200818010.12187@localhost.localdomain>
 <46A0AB44.70009@googlemail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Gabriel C <nix.or.die@googlemail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1761715AbXGTNG3@vger.kernel.org>
In-Reply-To: <46A0AB44.70009@googlemail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 20 Jul 2007, Gabriel C wrote:

> Robert P. J. Day wrote:

> > this has *nothing* to do with the aforementioned maturity levels.
> > i understand entirely the inconsistency above.  what i'm
> > suggesting is that it might very well be more appropriate to *drop
> > the dependency* rather than munge the prompt to add the qualifier.
>
> This is a thing the author/maintainer/subsystem maintainer should and need do.
>
> They know when something is not EXPERIMENTAL anymore.

agreed (sort of).  all i'm saying (and after this, i'll shut the heck
up about it) is that, if you find a Kconfig entry of the form:

config FUBAR
	prompt "whatever"
	depends on ... && EXPERIMENTAL

and you want to make that selection consistent, you have two
possibilities:

1) add "(EXPERIMENTAL)" to the prompt to match the dependency, or
2) drop the dependency on EXPERIMENTAL to match the prompt

  i contend that, *for now*, it's a better investment in time to find
entries like that that are *clearly* not experimental any more, and
drop the dependency.  not only will that make it consistent, but it's
unlikely that you'll ever have to *revert* that decision.

  OTOH, it's quite possible that, after you add the prompt suffix of
"(EXPERIMENTAL)" for consistency, the feature maintainer might come by
tomorrow and say something like, "nah, that feature's been around for
years, it's as stable as it gets," and will undo the patch you just
made, wasting your time and effort.

  lastly, i'm not convinced that it's *only* the feature maintainer
that can make that decision.  surely, there's enough clever people
here who can look at any given feature and say, "yeah, i've been using
that for years, it's rock solid, it's stupid to keep that dependent on
EXPERIMENTAL."

  all i'm saying is, if you want to put some time in here, it's better
invested in *removing* what are clearly ridiculous dependencies on
EXPERIMENTAL, rather than *adding* even more of that labelling to the
tree.

rday

p.s.  even if a given Kconfig entry *is* consistent, as in:

config SNAFU
	bool "... (EXPERIMENTAL)"
	depends on ... && EXPERIMENTAL
	...

  it's clear that there's a pile of *that* stuff for which all
references to EXPERIMENTAL can be dropped.  all in all, given the
possible cleanup here, i'm thinking that going in and *adding* more
EXPERIMENTAL clutter to the Kconfig files is going in exactly the
wrong direction.

--
========================================================================
Robert P. J. Day
Linux Consulting, Training and Annoying Kernel Pedantry
Waterloo, Ontario, CANADA

http://fsdev.net/wiki/index.php?title=Main_Page
========================================================================
