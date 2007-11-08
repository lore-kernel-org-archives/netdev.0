From: Al Viro <viro@ftp.linux.org.uk>
Subject: [RFC] dependencies for platform drivers (was Re: ax88796: add superh to kconfig dependencies)
Date: Thu, 8 Nov 2007 08:18:54 +0000
Message-ID: <20071108081854.GN8181@ftp.linux.org.uk>
References: <20071108073105.3996.70418.sendpatchset@clockwork.opensource.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, lethal@linux-sh.org, ben-linux@fluff.org,
	akpm@linux-foundation.org, jeff@garzik.org,
	linux-arch@vger.kernel.org
To: Magnus Damm <magnus.damm@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:40277 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750708AbXKHITH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Nov 2007 03:19:07 -0500
Content-Disposition: inline
In-Reply-To: <20071108073105.3996.70418.sendpatchset@clockwork.opensource.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 08, 2007 at 04:31:05PM +0900, Magnus Damm wrote:
>  config AX88796
>  	tristate "ASIX AX88796 NE2000 clone support"
> -	depends on ARM || MIPS
> +	depends on ARM || MIPS || SUPERH

You know, that really sucks more and more.  How about doing the following:
	a) making it depend on PLAT_HAS_AX88796
	b) adding selects for all subarchitectures that have the corresponding
platform device
and setting that as a uniform policy for platform drivers?  For things like
SM501 we would do
config MFD_SM501
	depends on PCI || PLAT_HAS_SM501
etc.

Seriously, folks, we are getting shitloads of platform drivers with no
dependencies whatsoever, needed on a handful of targets and occasionally
failing to build on unrelated architectures.  Moreover, having a list
of architectures in dependencies for each of those suckers is a PITA
from the conflict POV.  Not to mention platform drivers that fall into
the mainline kernel with not a single platform device for them, etc.

Comments?
