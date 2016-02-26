From: Thomas Graf <tgraf@suug.ch>
Subject: Re: header conflict introduced by change to
 netfilter_ipv4/ip_tables.h
Date: Fri, 26 Feb 2016 10:13:07 +0100
Message-ID: <20160226091307.GA20785@pox.localdomain>
References: <20160106092007.1c5a0c75@xeon-e3>
 <20160225210856.GB10608@pox.localdomain>
 <20160226071817.GG6104@lakka.kapsi.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemming@brocade.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Mikko Rapeli <mikko.rapeli@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:36469 "EHLO
	mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750739AbcBZJNK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2016 04:13:10 -0500
Received: by mail-wm0-f51.google.com with SMTP id g62so63843337wme.1
        for <netdev@vger.kernel.org>; Fri, 26 Feb 2016 01:13:10 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20160226071817.GG6104@lakka.kapsi.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/26/16 at 09:18am, Mikko Rapeli wrote:
> On Thu, Feb 25, 2016 at 10:08:56PM +0100, Thomas Graf wrote:
> > There is another issue with this commit. iptables.h included from m_ipt.c
> > includes  xtables.h which includes <xtables-version.h> which is not
> > available on a system without xtables.
> > 
> > gcc -Wall -Wstrict-prototypes  -Wmissing-prototypes -Wmissing-declarations -Wold-style-definition -Wformat=2 -O2 -I../include -DRESOLVE_HOSTNAMES -DLIBDIR=\"/usr/lib\" -DCONFDIR=\"/etc/iproute2\" -D_GNU_SOURCE -D_FILE_OFFSET_BITS=64 -D_LARGEFILE_SOURCE -D_LARGEFILE64_SOURCE  -DHAVE_SETNS -DHAVE_ELF -DCONFIG_GACT -DCONFIG_GACT_PROB -DIPT_LIB_DIR=\"/lib/xtables\" -DYY_NO_INPUT   -c -o m_ipt.o m_ipt.c
> > In file included from ../include/iptables.h:5:0,
> >                  from m_ipt.c:17:
> > ../include/xtables.h:34:29: fatal error: xtables-version.h: No such file or directory
> >  #include <xtables-version.h>
> 
> I don't see any dependencies from kernel side uapi headers to iptables or
> xtables in my tree based on v4.5-rc2. Maybe this is a problem in
> iproute2.

Right, it's an iproute2 issue in the commit to backport these original
changes to iproute2:

commit 5cd1adba79d33644debd4ba498bb262c5bebcfba
Author: Stephen Hemminger <stephen@networkplumber.org>
Date:   Sun Jan 3 15:14:27 2016 -0800

    Update to current iptables headers
    
    Keep in sync with current iptables upstream
