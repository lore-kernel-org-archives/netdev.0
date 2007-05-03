From: "Robert P. J. Day" <rpjday@mindspring.com>
Subject: Re: finding your own dead "CONFIG_" variables
Date: Thu, 3 May 2007 06:19:20 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0705030613120.32556@localhost.localdomain>
References: <Pine.LNX.4.64.0705030400120.20539@localhost.localdomain>
 <a781481a0705030237l7d636b55t93f2ee5151cd7709@mail.gmail.com>
 <Pine.LNX.4.64.0705030546310.29962@localhost.localdomain>
 <200705031202.56805.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323328-1133002977-1178187560=:32556"
Cc: Satyam Sharma <satyam.sharma@gmail.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nic.NetDirect.CA ([216.16.235.2]:49472 "EHLO
	rubicon.netdirect.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031150AbXECKUL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 May 2007 06:20:11 -0400
In-Reply-To: <200705031202.56805.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323328-1133002977-1178187560=:32556
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Thu, 3 May 2007, Arnd Bergmann wrote:

> On Thursday 03 May 2007, Robert P. J. Day wrote:
> > > Suggest: configfiles=$(find . -name 'Kconfig*' -or -name '*defconfig*')
> > >
> > > Some CONFIG_ options exist that are not declared anywhere in the
> > > Kconfig files but defined directly in the arch/.../*defconfig*
> > > files.
> >
> > it's my understanding that entries in any defconfig files are
> > *automatically* pruned at some point once a CONFIG_ variable no longer
> > exists in any Kconfig file, so i'm not going to be touching those
> > files.  also, adding that extra check wouldn't add anything useful to
> > the output.
>
>
> An interesting category would be a symbol that is
>
> - used in a source file
> - defined in an old defconfig
> - not present in any Kconfig* file
>
> If any of these exist, I would consider them _worse_ than the ones
> found by your initial script, because some functionality that once
> was there has been recently removed.

hmmmmmm ... i see your point now -- not present in any Kconfig file
but still being selected by a defconfig file that might still be
affecting the eventual build.  that's an easy enough change to make
but, as i've mentioned before, this output could be reduced
substantially if developers stopped using CONFIG_ prefixed macro names
for their own non-Kconfig variables (*cough* MTD *cough* :-).

but, again, some of that issue might disappear if those defconfig
files were auto-regenerated on a timely basis (if that is, in fact,
how they're kept up to date).

rday

-- 
========================================================================
Robert P. J. Day
Linux Consulting, Training and Annoying Kernel Pedantry
Waterloo, Ontario, CANADA

http://fsdev.net/wiki/index.php?title=Main_Page
========================================================================
--8323328-1133002977-1178187560=:32556--
