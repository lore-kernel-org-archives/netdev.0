From: Anders =?iso-8859-1?Q?Grafstr=F6m?=
	<grfstrm@users.sourceforge.net>
Subject: Re: e100: Wait for PHY reset to complete?
Date: Tue, 31 Oct 2006 19:10:43 +0100 (CET)
Message-ID: <28176.212.247.11.6.1162318243.squirrel@webmail.sys.kth.se>
References: <453F9D4A.8090306@users.sourceforge.net>   
    <20061025185656.GA19037@electric-eye.fr.zoreil.com>   
    <453FC693.10705@intel.com> <453FD677.7060405@intel.com>
    <3699.82.182.159.28.1161819386.squirrel@webmail.sys.kth.se>
    <45400A6D.4020704@intel.com> <45464D0D.50802@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Francois Romieu" <romieu@fr.zoreil.com>, netdev@vger.kernel.org,
	"Jesse Brandeburg" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.kth.se ([130.237.48.97]:12420 "EHLO mx3.kth.se")
	by vger.kernel.org with ESMTP id S1423728AbWJaSKt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2006 13:10:49 -0500
In-Reply-To: <45464D0D.50802@intel.com>
To: "Auke Kok" <auke-jan.h.kok@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>> Anders Grafstr=F6m wrote:
>>> I ran mii-diag when the LEDs went out and the register dump
>>> said it was in loopback. It is somewhat difficult reproduce.
>>> It seems to be timing dependent, something else has to occur
>>> at the same time.
>>> I must confess I have only seen it with the 2.6.13 kernel.
>>> I have not been able to reproduce it with 2.6.18.
>>> But I have found no change in the driver that would fix it so
>>> I suspect the problem is still there.

Now looking at mdio_ctrl(), which implements mdio_write() and mdio_read=
(),
I see that this patch
http://kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.15/2.6.1=
5-mm3/broken-out/corruption-during-e100-mdi-register-access.patch
most likely fixed the problem that I have experienced.

"although access to the MDI registers involves
multiple steps which must not be intermixed, nothing was defending agai=
nst
two or more threads attempting simultaneous access.  The most obvious
situation where such interference could occur involves the watchdog ver=
sus
ioctl paths"

Sorry for the noise.
Thanks,
Anders


