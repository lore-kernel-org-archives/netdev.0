From: lsorense@csclub.uwaterloo.ca (Lennart Sorensen)
Subject: Re: MediaGX/GeodeGX1 requires X86_OOSTORE. (Was: Re: Strange connection slowdown on pcnet32)
Date: Fri, 16 Feb 2007 19:00:19 -0500
Message-ID: <20070217000019.GH7582@csclub.uwaterloo.ca>
References: <32943920.1119801171642884331.JavaMail.root@vms226.mailsrvcs.net> <20070216172110.GC7582@csclub.uwaterloo.ca> <20070216202300.GD7585@csclub.uwaterloo.ca> <20070216210157.GE7585@csclub.uwaterloo.ca> <20070216222728.GF7585@csclub.uwaterloo.ca> <20070216224824.GG7585@csclub.uwaterloo.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: pcnet32@verizon.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from caffeine.uwaterloo.ca ([129.97.134.17]:35425 "EHLO
	caffeine.csclub.uwaterloo.ca" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1946325AbXBQAAU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Feb 2007 19:00:20 -0500
Content-Disposition: inline
In-Reply-To: <20070216224824.GG7585@csclub.uwaterloo.ca>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 16, 2007 at 05:48:24PM -0500, Lennart Sorensen wrote:
> Well so far it really looks like enabling OOSTORE on the Geode
> SC1200/GX1 really does make a difference.  A bit of searching seems to
> indicate the person that originally submitted the patch that enabled
> load/store reordering on the MediaGX/Geode though it might need OOSTORE,
> but was convinced by others it didn't.  Looks like it really does need
> it.  The failure that occoured before within a few seconds of starting a
> large transfer, no longer fails and all I did was enable
> CONFIG_X86_OOSTORE, and recompile pcnet32.ko and load the new module on
> the running system.  Moving back to the pcnet32.ko built without OOSTORE
> enabled hits the failure again within seconds, until ifconfig eth1
> down/up reinitialized it's descriptor ring, after which it survices
> another bit of transfer and then fails again.

Well forcing load/store serialize on the CPU doesn't help, disalbing
memory bypass doesn't help.  Enabling the X86_OOSTORE does help.  What a
stupid CPU design.

So far nothing has managed to fix the __memcpy_toio in the jsm driver
getting data out of order when sending on an exar pci uart chip.  Only
calling memcpy with one byte at a time seems to work there.  Works fine
on every other cpu of course.  What else am I going to discover is wrong
with this CPU.

--
Len Sorensen
