From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH/RFC net-next 0/4] Delete token ring support.
Date: Wed, 16 May 2012 11:29:59 +0200
Message-ID: <87sjf0a2y0.fsf@nemi.mork.no>
References: <1337128544-18680-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	linux390@de.ibm.com, linux-s390@vger.kernel.org
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:59898 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752879Ab2EPJa2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 May 2012 05:30:28 -0400
In-Reply-To: <1337128544-18680-1-git-send-email-paul.gortmaker@windriver.com>
	(Paul Gortmaker's message of "Tue, 15 May 2012 20:35:40 -0400")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Paul Gortmaker <paul.gortmaker@windriver.com> writes:

> This may not be for 35-next, but for addition to feature-removal.txt
> and application at a later date.  But what I would like to get is
> consensus that this is something that we want to proceed with before =
I
> spend any more time on it.  If folks are OK with the idea, then I am
> open to suggestions as to the best time for it to happen.
>
> So, why you might ask?  It is in tree already, it is "free" to leave =
it
> there, right?  Well, no.
>
> What led me here was the creation of a patch to remove CONFIG_MCA.  I=
n
> doing so, I found I was deleting most of the token ring drivers, and=20
> altering the remaining few ISA/MCA ones to be just ISA only.

With all due respect, I do not think you have looked thoroughly enough
at the remaining drivers...

> But it really didn't make sense to me, to just leave the skeletal
> remains of token ring there -- vs removing TR 1st, and then the MCA
> removal will be a lot smaller and cleaner commit.
>
> Removal: does it make sense?
>
> The biggest data point I can suggest to folks is to run:
>
> 	git whatchanged --follow drivers/net/tokenring
>
> and when you are quickly paging over the changes, note two things.
> (1) the amount of time spent by folks cleaning and maintaining the
> code, and (2) - most important -- is that essentially all the commits
> are of the tree-wide cleanup nature, or API change nature.
>
> What I mean by (2) is the implicit absence of anyone fixing _runtime_
> bugs, going all the way back to 2.6.12 in 2005.  If the code was bein=
g
> _used_, we'd see runtime regressions reported and their associated fi=
xes.

I think you underestimate the girls(?) and guys doing tree-wide cleanup=
s
and API changes.  Network driver regressions are pretty much limited to
actively developed and maintained drivers.

> A search on the internet for users tends to show that even the die ha=
rd
> enthusiasts who cared to poke at MCA/TR just for hobby sake have pret=
ty
> much all given up somewhere in the 2003-2005 "pre-git" timeframe, and
> never really moved off their 2.4.x kernels.
>
> This is no surprise, since on x86, MCA (and hence most tokenring
> users) was limited to the lowly 386sx-16 PS/2 with typically 4MB RAM.
> Some "high end" 486 machines existed, and in theory could be fitted
> with max 64MB RAM (default 16MB).  I don't think anyone will debate
> that such hardware with such limited memory is ever going to be usefu=
l
> in a 3.x kernel use case.

Beware, I am considering sending you a triple lanstreamer PCI card  :-)

Seriously, there are both PCI and PCMCIA TokenRing cards, and nothing
prevents them from being used with modern x86 hardware.  The lanstreame=
r
driver is disabled for 64bit systems, but I still don't think removing
it is appropriate.  It will work in 32bit mode in any shiny new PC stil=
l
having PCI slots.  And the 3c359 should work in any laptop with a
Cardbus slot, if those still exist.  But I don't see anyone proposing
removing the PCMCIA/Cardbus support just yet....



Bj=C3=B8rn
