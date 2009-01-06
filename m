From: David Miller <davem@davemloft.net>
Subject: Re: [GIT]: Networking
Date: Tue, 06 Jan 2009 08:12:33 -0800 (PST)
Message-ID: <20090106.081233.50701367.davem@davemloft.net>
References: <20090106055144.GA11695@uranus.ravnborg.org>
	<20090105.220742.176919041.davem@davemloft.net>
	<20090106081135.GA12695@uranus.ravnborg.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jaswinderlinux@gmail.com, torvalds@linux-foundation.org,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, dwmw2@infradead.org
To: sam@ravnborg.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56006
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751934AbZAFQMc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2009 11:12:32 -0500
In-Reply-To: <20090106081135.GA12695@uranus.ravnborg.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sam Ravnborg <sam@ravnborg.org>
Date: Tue, 6 Jan 2009 09:11:35 +0100

> One of the pratical issues I have with this is when to read which files.
> 
> What we could do is something like:
> 
> - during *config scan all "wildcard enabled" directories
>   and read the Kconfig info from the relevant .C files.
> - record which .C files which included Kconfig and do
>   an automatic "scan + oldconfig" when one of these files
>   changes
> 
> When we add new Kconfig info to a file we would have
> to manually do the *config to trigger a scan for the .C files

Yes, this is the only cheap way to do this.

Note, we are already scanning the full source files using a custom
tool to generate dependencies.... oh nevermind, we used to use a
custom tool, we seem to be just transforming gcc -MD output now.

Anyways, if we were still using that custom optimized parser we could
have put the Kconfig/Makefile info extracter in there.
