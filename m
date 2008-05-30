From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH] drivers/net: remove network drivers' last few uses of IRQF_SAMPLE_RANDOM
Date: Fri, 30 May 2008 21:50:52 +0200
Message-ID: <20080530195051.GA4980@ucw.cz>
References: <482C8D4D.3040702@garzik.org> <20080516132107.GA11304@csclub.uwaterloo.ca> <20080516161029.44ded734@core> <20080516173610.GA27126@csclub.uwaterloo.ca> <20080516191125.46f59ad6@core> <a24804730805162155m72e6b40aweb8822515c880c50@mail.gmail.com> <1211728189.5913.71.camel@andromache> <20080525232712.GF5970@mit.edu> <20080526154326.1fe44214@Varda> <20080526111458.fff6c311.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alejandro Riveira =?iso-8859-1?Q?Fern=E1ndez?=
	<ariveira@gmail.com>, Theodore Tso <tytso@MIT.EDU>,
	Glen Turner <gdt@gdt.id.au>,
	Chris Peterson <cpeterso@cpeterso.com>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Lennart Sorensen <lsorense@csclub.uwaterloo.ca>,
	Jeff Garzik <jeff@garzik.org>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	Rick Jones <rick.jones2@hp.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Bill Fink <billfink@mindspring.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755147AbYE3Tva@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20080526111458.fff6c311.billfink@mindspring.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi!

> >  Just a shot in the dark... would hw sensors (raw data) chips be a good source
> >  of entropy for /dev/random ?? 
> 
> For systems with high resolution timers, even if an attacker has total
> knowledge/control of the network, it doesn't seem realistically possible
> for them to determine the low order bits of the nanosecond timer of
> disk and network I/O system calls, if those were used as a source of
> entropy.  I think this is a case of the (unrealistic) best being an
> enemy of the common (and realistic) good.
> 
> Another idea that occured to me:  How about using the low order bits
> of the instruction memory address being executed that was interrupted
> by the HZ timer interrupt.  This also doesn't seem to be something
> that an external attacker could realistically determine.  And a
> combination of these approaches would be that much stronger, combined
> of course with any other available entropy sources.

Well, I'd fear that hlt instruction in idle loop would be the one
interrupted most. But low bits of tsc at timer interrupt would be fine
entropy source.

..actually, bogomips varies a bit between boots, maybe we should hash
it into the pool?

Maybe we could even redo bogomips calculation at runtime and use low
bits as random numbers? :-).
							Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
