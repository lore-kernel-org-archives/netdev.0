From: Henrique de Moraes Holschuh <hmh@hmh.eng.br>
Subject: Re: [PATCH] drivers/net: remove network drivers' last few uses of
	IRQF_SAMPLE_RANDOM
Date: Thu, 15 May 2008 19:29:41 -0300
Message-ID: <20080515222941.GB20976@khazad-dum.debian.net>
References: <20080515142154.0595e475@core> <36D9DB17C6DE9E40B059440DB8D95F52052D71BB@orsmsx418.amr.corp.intel.com> <482C7B18.6060003@garzik.org> <482C7E53.3050300@hp.com> <482C8184.2030906@garzik.org> <482C8550.5000909@intel.com> <482C8D4D.3040702@garzik.org> <a24804730805151301s3c6644d0hc2c78b8008fe035d@mail.gmail.com> <20080515214721.GP18825@mit.edu> <482CB1FB.7080807@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Theodore Tso <tytso@mit.edu>,
	Chris Peterson <cpeterso@cpeterso.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	Rick Jones <rick.jones2@hp.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1.smtp.messagingengine.com ([66.111.4.25]:59295 "EHLO
	out1.smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752253AbYEOW3p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2008 18:29:45 -0400
Content-Disposition: inline
In-Reply-To: <482CB1FB.7080807@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 15 May 2008, Jeff Garzik wrote:
> rngd is already deployed in most distros, via rng-tools.  Motivated  
> people are welcome to steal maintainership from me...

I was, once.  But I got into the trap of getting too out of sync from
upsteam rngd, and suddenly, packaging all those changes into incremental
patches become too much non-fun work for me to find the energy to do so.

It has been a few years since I really looked at that code, except for a
few minor Debian packaging fixes.  It is old code, and if my C is not
world-class now, it was even worse at that time.  But at least valgrind
tells me I fixed the worst bugs, and FIPS 140-2 (the old version of it
that still had criteria for non-deterministic RNGs) and DIEHARD couldn't
find any issues with its output after several runs on gigabyte-sized
files produced both from an Intel FWH RNG, and from a VIA PadLock RNG.

If anyone wants to poke at it, get the Debian rng-tools source package.
It directly supports the VIA PadLock in userspace in a suitably paranoid
mode (checks that the RNG was not reprogrammed at every read), and does
multithreading so that FIPS and output processing does not block (nor
gets blocked) by /dev/hw_random reading, etc.

Lots of cowebs on it, though.  And you probably need to get the version
in Debian unstable AND the version in Debian experimental, to get the
full code.  If someone really wants to work on it, I can send the VC
repo for them to play with.

-- 
  "One disk to rule them all, One disk to find them. One disk to bring
  them all and in the darkness grind them. In the Land of Redmond
  where the shadows lie." -- The Silicon Valley Tarot
  Henrique Holschuh
