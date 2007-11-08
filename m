From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC] dependencies for platform drivers (was Re: ax88796: add
 superh to kconfig dependencies)
Date: Thu, 8 Nov 2007 01:02:47 -0800
Message-ID: <20071108010247.3144394c.akpm@linux-foundation.org>
References: <20071108073105.3996.70418.sendpatchset@clockwork.opensource.se>
	<20071108081854.GN8181@ftp.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: magnus.damm@gmail.com, netdev@vger.kernel.org, lethal@linux-sh.org,
	ben-linux@fluff.org, jeff@garzik.org, linux-arch@vger.kernel.org
To: Al Viro <viro@ftp.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:47782 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753879AbXKHJDv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Nov 2007 04:03:51 -0500
In-Reply-To: <20071108081854.GN8181@ftp.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> On Thu, 8 Nov 2007 08:18:54 +0000 Al Viro <viro@ftp.linux.org.uk> wrote:
> On Thu, Nov 08, 2007 at 04:31:05PM +0900, Magnus Damm wrote:
> >  config AX88796
> >  	tristate "ASIX AX88796 NE2000 clone support"
> > -	depends on ARM || MIPS
> > +	depends on ARM || MIPS || SUPERH
> 
> You know, that really sucks more and more.  How about doing the following:
> 	a) making it depend on PLAT_HAS_AX88796
> 	b) adding selects for all subarchitectures that have the corresponding
> platform device
> and setting that as a uniform policy for platform drivers?

Yup, but we should be religious about the naming conventions.  ARCH_HAS_
and PLAT_HAS_ followed by the exact name of the thus-enabled config option.

>  For things like
> SM501 we would do
> config MFD_SM501
> 	depends on PCI || PLAT_HAS_SM501
> etc.

See, bug.  That should be PLAT_HAS_MFD_SM501

> Seriously, folks, we are getting shitloads of platform drivers with no
> dependencies whatsoever, needed on a handful of targets and occasionally
> failing to build on unrelated architectures.  Moreover, having a list
> of architectures in dependencies for each of those suckers is a PITA
> from the conflict POV.  Not to mention platform drivers that fall into
> the mainline kernel with not a single platform device for them, etc.
> 
> Comments?

grep PPC drivers/*/Kconfig and weep.
