From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [RFC] should we care of COMPAT mode in bridge ?
Date: Mon, 6 Jun 2011 22:31:32 +0200
Message-ID: <201106062231.32226.arnd@arndb.de>
References: <1307389540.2642.3.camel@edumazet-laptop> <20110606.130309.847468074358617705.davem@davemloft.net> <4DED3759.7030209@genband.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	netdev@vger.kernel.org
To: Chris Friesen <chris.friesen@genband.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.171]:57400 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756523Ab1FFUbf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2011 16:31:35 -0400
In-Reply-To: <4DED3759.7030209@genband.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 06 June 2011 22:23:53 Chris Friesen wrote:
> It raises an interesting question though...do we plan on supporting 
> compat indefinitely?
> 
> As I see it x86 generally makes more sense to run as 64-bit when 
> possible due to the extra register availability. Compat is primarily 
> useful for the embedded space and for backwards compatibility, and 
> ripping it out would cause a lot of grief for legacy 32-bit apps.  It 
> would simplify the userspace/kernel interface though.

There are a lot of applications that require being run as 32 bit,
and some of them are much happier in a chroot environment. Removing
the compat support entirely won't be an option for the next 10 years
at least, AFAICT. Even if we get all x86 folks to migrate to 64 bits
at some point in the distant future, there will always be other
architectures that make the move to 64 bits.

Note that there is currently work going on to add a new x32 ABI
to arch/x86 which makes it possible to use 32 bit pointers with the
full 64 bit register set. If this becomes a success, we will never
be able to build x86 kernels without compat support.

	Arnd
