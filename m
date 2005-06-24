From: Linus Torvalds <torvalds@osdl.org>
Subject: Re: [git patch] urgent e1000 fix
Date: Fri, 24 Jun 2005 01:51:46 -0700 (PDT)
Message-ID: <Pine.LNX.4.58.0506240149440.11175@ppc970.osdl.org>
References: <13661.1119601379@kao2.melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Denis Vlasenko <vda@ilport.com.ua>,
	Jeff Garzik <jgarzik@pobox.com>,
	David Lang <david.lang@digitalinsight.com>,
	Andrew Morton <akpm@osdl.org>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	Netdev List <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S262705AbVFXIx2@vger.kernel.org>
To: Keith Owens <kaos@ocs.com.au>
In-Reply-To: <13661.1119601379@kao2.melbourne.sgi.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Fri, 24 Jun 2005, Keith Owens wrote:

> On Fri, 24 Jun 2005 09:49:05 +0300, 
> Denis Vlasenko <vda@ilport.com.ua> wrote:
> >On Friday 24 June 2005 02:33, Linus Torvalds wrote:
> >> To actually allow real fuzz or to allow real whitespace differences in the
> >> patch data itself is a _much_ bigger issue than this trivial patch
> >> corruption, and I'd prefer to avoid going there if at all possible.
> >
> >How about automatic stripping of _trailing_ whitespace on all incoming
> >patches? IIRC no file type (C, sh, Makefile, you name it) depends on
> >conservation of it, thus it's 100% safe.
> 
> One (admittedly rare) case - adding a text file that contains an
> embedded patch, so you have a patch that includes a patch.  This is
> sometimes done in Documentation files when an external file has to be
> changed.  In embedded patch, empty lines are converted to a single
> space, which then appears as trailing whitespace.  Not sure if that is
> a big enough reason not to strip whitespace.

There's a much more important reason never _ever_ to mess with whitespace
in patches: it by definition measn that the resulting whitespace now does
not match the thing at the other end, and that _will_ mean merge problems
later (ie subsequent patches will have increasingly incorrect whitespace,
and now everybody has to live with whitespace not being reliable).

So no. The only reliable way to handle whitespace is to never corrupt it. 
Don't make excuses for broken email clients etc.

		Linus
