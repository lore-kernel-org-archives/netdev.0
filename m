From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] drivers/net: remove network drivers' last few uses of IRQF_SAMPLE_RANDOM
Date: Mon, 26 May 2008 23:11:21 +0100
Message-ID: <20080526221119.GF28241@solarflare.com>
References: <20080516161029.44ded734@core> <20080516173610.GA27126@csclub.uwaterloo.ca> <20080516191125.46f59ad6@core> <a24804730805162155m72e6b40aweb8822515c880c50@mail.gmail.com> <1211728189.5913.71.camel@andromache> <20080525232712.GF5970@mit.edu> <20080526154326.1fe44214@Varda> <20080526111458.fff6c311.billfink@mindspring.com> <m38wxwepvt.fsf@maximus.localdomain> <20080526175227.4b7ae764.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Krzysztof Halasa <khc@pm.waw.pl>,
	Alejandro Riveira =?iso-8859-1?Q?Fern=E1ndez?=
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from 82-69-137-158.dsl.in-addr.zen.co.uk ([82.69.137.158]:50990 "EHLO
	uklogin.uk.level5networks.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755159AbYEZWMm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 May 2008 18:12:42 -0400
Content-Disposition: inline
In-Reply-To: <20080526175227.4b7ae764.billfink@mindspring.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bill Fink wrote:
> On Mon, 26 May 2008, Krzysztof Halasa wrote:
> 
> > Bill Fink <billfink@mindspring.com> writes:
> > 
> > > Another idea that occured to me:  How about using the low order bits
> > > of the instruction memory address being executed that was interrupted
> > > by the HZ timer interrupt.
> > 
> > Think of constant-instructions-length processors :-)
> 
> I'm not sure what you're driving at, but if it's that you shouldn't
> use the very last 2 or 3 bits, then sure those should be excluded.
> But that still leaves 9 or 10 bits at least in the page offset, and
> that's being conservative in the number of address bits to sample.

We would still need to exclude any tight loops which an attacker could
predict or influence a process to enter - the idle loop obviously, plus
udelay(), memcpy() and probably many other functions.  Some such loops may
be in userland and therefore unknown to us.  So there might not be nearly
as many bits of entropy in the program counter as could be naively
expected.  What's more, once userland is blocked on /dev/random, there is
no more entropy available from the program counter!

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
