From: takada <takada@mbf.nifty.com>
Subject: Re: MediaGX/GeodeGX1 requires X86_OOSTORE.
Date: Sat, 17 Feb 2007 23:11:13 +0900 (JST)
Message-ID: <20070217.231113.193678444.takada@mbf.nifty.com>
References: <20070216222728.GF7585@csclub.uwaterloo.ca>
	<20070216224824.GG7585@csclub.uwaterloo.ca>
	<20070217000019.GH7582@csclub.uwaterloo.ca>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pcnet32@verizon.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: lsorense@csclub.uwaterloo.ca
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1946755AbXBQOMG@vger.kernel.org>
In-Reply-To: <20070217000019.GH7582@csclub.uwaterloo.ca>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: lsorense@csclub.uwaterloo.ca (Lennart Sorensen)
Subject: Re: MediaGX/GeodeGX1 requires X86_OOSTORE. (Was: Re: Strange connection slowdown on pcnet32)
Date: Fri, 16 Feb 2007 19:00:19 -0500

> On Fri, Feb 16, 2007 at 05:48:24PM -0500, Lennart Sorensen wrote:
> > Well so far it really looks like enabling OOSTORE on the Geode
> > SC1200/GX1 really does make a difference.  A bit of searching seems to
> > indicate the person that originally submitted the patch that enabled
> > load/store reordering on the MediaGX/Geode though it might need OOSTORE,
> > but was convinced by others it didn't.  Looks like it really does need
> > it.  The failure that occoured before within a few seconds of starting a
> > large transfer, no longer fails and all I did was enable
> > CONFIG_X86_OOSTORE, and recompile pcnet32.ko and load the new module on
> > the running system.  Moving back to the pcnet32.ko built without OOSTORE
> > enabled hits the failure again within seconds, until ifconfig eth1
> > down/up reinitialized it's descriptor ring, after which it survices
> > another bit of transfer and then fails again.
> 
> Well forcing load/store serialize on the CPU doesn't help, disalbing
> memory bypass doesn't help.  Enabling the X86_OOSTORE does help.  What a
> stupid CPU design.

is it mean what doesn't help with doesn't call set_cx86_reoder()?
this function disable to reorder at 0x4000:0000 to 0xffff:ffff.
does pcnet32 access at out of above range?

--- arch/i386/Kconfig.cpu~	2007-02-05 03:44:54.000000000 +0900
+++ arch/i386/Kconfig.cpu	2007-02-17 21:25:52.000000000 +0900
@@ -322,7 +322,7 @@ config X86_USE_3DNOW
 
 config X86_OOSTORE
 	bool
-	depends on (MWINCHIP3D || MWINCHIP2 || MWINCHIPC6) && MTRR
+	depends on (MWINCHIP3D || MWINCHIP2 || MWINCHIPC6) && MTRR || MGEODEGX1
 	default y
 
 config X86_TSC
