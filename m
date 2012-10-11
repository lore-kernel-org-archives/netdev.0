From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: alignment faults in 3.6
Date: Thu, 11 Oct 2012 09:53:02 +0100
Message-ID: <20121011085302.GM4625@n2100.arm.linux.org.uk>
References: <CAG5Tg6V0Vj9HTy3=AU-q+Qa3DuJs6R1Kw+3uOWU_jOGfkgyXzw@mail.gmail.com> <20121005071216.GD4625@n2100.arm.linux.org.uk> <CAG5Tg6VciuxJ=k+fatzLugcehF54mGNOLHpUwdMX99oCnAVg8Q@mail.gmail.com> <20121005082439.GF4625@n2100.arm.linux.org.uk> <506ED18C.3010009@gmail.com> <20121005140556.GQ4625@n2100.arm.linux.org.uk> <506EEFBB.3060705@gmail.com> <507619FA.6080001@jonmasters.org> <yw1xtxu1pwtv.fsf@unicorn.mansr.com> <AE90C24D6B3A694183C094C60CF0A2F6026B7038@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: =?iso-8859-1?Q?M=E5ns_Rullg=E5rd?= <mans@mansr.com>,
	Jon Masters <jonathan@jonmasters.org>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caramon.arm.linux.org.uk ([78.32.30.218]:50172 "EHLO
	caramon.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752211Ab2JKIxV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2012 04:53:21 -0400
Content-Disposition: inline
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B7038@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 11, 2012 at 09:21:35AM +0100, David Laight wrote:
> It might be enough to use __attribute__((aligned(2))) on some structure
> members (actually does 'ldm' need 8 byte alignment?? - in which case
> aligned(4) is enough).

No, ldm just needs 4 byte alignment, the same as normal word loads/stores
not to fault.  The only instructions which needs 8 byte alignment not to
fault are the double-word load/stores.

> One on my bugbears is hardware that will once receive ethernet frames
> onto a 4n boundary - it needs to be 4n+2. two bytes of 'junk' will do.

Indeed, but remember that is just a mere optimisation for IPv4.  What
may be true of IPv4 is not necessarily true of other protocols, though
IPv4 is currently the dominant protocol today.  IPv6 follows the same
alignment rules as IPv4, so it's unlikely to change.
