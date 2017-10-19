From: Adam Borowski <kilobyte@angband.pl>
Subject: Re: [PATCH] wanxl: use m68k-linux-gnu-as if available
Date: Thu, 19 Oct 2017 21:31:48 +0200
Message-ID: <20171019193148.s46nggjo66255rgn@angband.pl>
References: <20171012232434.15890-1-kilobyte@angband.pl>
 <20171018.120812.879877583327430024.davem@davemloft.net>
 <20171018113326.2rkpe7wrlzihwdyb@angband.pl>
 <20171018.130721.1208428223967129203.davem@davemloft.net>
 <m3y3o7nj7m.fsf@pm.waw.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Krzysztof Halasa <khc@pm.waw.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tartarus.angband.pl ([89.206.35.136]:38922 "EHLO
        tartarus.angband.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750968AbdJSTb4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Oct 2017 15:31:56 -0400
Content-Disposition: inline
In-Reply-To: <m3y3o7nj7m.fsf@pm.waw.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 19, 2017 at 07:25:17PM +0200, Krzysztof Halasa wrote:
> David Miller <davem@davemloft.net> writes:
> 
> > We don't even know if whatever "as68k" is would be the same thing
> > as GNU as and generate the same binaries.
> 
> It's GNU as, likewise ld68k, though I have no idea if recent versions
> would compile/link the firmware (correctly). This is 15+ years old.

Thus, we know that:

* this patch can't possibly make things worse: it merely makes compilation
  succeed on systems (like Debian + derivatives) that name m68k GNU as
  m68k-linux-gnu-as rather than as68k

* modern versions of "rose by any other name" (GNU as + ld) produce an
  output that's not byte-to-byte identical.  This would be understandable
  for a compiler, spells trouble for an assembler.  It's possible the modern
  interpretation is still valid, but if it's not, the current rule to
  rebuild the firmware has bitrotten (needs to pass some options to as?)

> I don't have opinion on the patch.

Do you still have access to such hardware?  Could you test it?

Because two scenarios are possible:
*) the build still works (in which case my patch fixes randconfigs on
   Debian)
*) it does not, and you have no resources to fix it.  In which case, it
   would be better to disable the automatic rule and add a comment "to
   build this firmware, dig an ancient version of as+ld".  Or perhaps
   remove this driver as unmaintaineable.


Meow!
-- 
⢀⣴⠾⠻⢶⣦⠀ Laws we want back: Poland, Dz.U. 1921 nr.30 poz.177 (also Dz.U. 
⣾⠁⢰⠒⠀⣿⡁ 1920 nr.11 poz.61): Art.2: An official, guilty of accepting a gift
⢿⡄⠘⠷⠚⠋⠀ or another material benefit, or a promise thereof, [in matters
⠈⠳⣄⠀⠀⠀⠀ relevant to duties], shall be punished by death by shooting.
