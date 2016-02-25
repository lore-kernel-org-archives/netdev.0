From: Thomas Graf <tgraf@suug.ch>
Subject: Re: header conflict introduced by change to
 netfilter_ipv4/ip_tables.h
Date: Thu, 25 Feb 2016 22:08:56 +0100
Message-ID: <20160225210856.GB10608@pox.localdomain>
References: <20160106092007.1c5a0c75@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	Mikko Rapeli <mikko.rapeli@iki.fi>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:37924 "EHLO
	mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750716AbcBYVI7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2016 16:08:59 -0500
Received: by mail-wm0-f42.google.com with SMTP id a4so45135946wme.1
        for <netdev@vger.kernel.org>; Thu, 25 Feb 2016 13:08:58 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20160106092007.1c5a0c75@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/06/16 at 09:20am, Stephen Hemminger wrote:
> This commit breaks compilation of iproute2 with net-next.
> 
> commit 1ffad83dffd675cd742286ae82dca7d746cb0da8
> Author: Mikko Rapeli <mikko.rapeli@iki.fi>
> Date:   Thu Oct 15 07:56:30 2015 +0200
> 
>     netfilter: fix include files for compilation
>     
>     Add missing header dependencies and other small changes so that each file
>     compiles alone in userspace.
>     
>     Signed-off-by: Mikko Rapeli <mikko.rapeli@iki.fi>
>     Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
> 
> For iproute2, a copy of kernel headers (from make install_headers) is used.
> After this change. the build of x_tables.c fails because IFNAMSIZ is already
> defined in net/if.h

There is another issue with this commit. iptables.h included from m_ipt.c
includes  xtables.h which includes <xtables-version.h> which is not
available on a system without xtables.

gcc -Wall -Wstrict-prototypes  -Wmissing-prototypes -Wmissing-declarations -Wold-style-definition -Wformat=2 -O2 -I../include -DRESOLVE_HOSTNAMES -DLIBDIR=\"/usr/lib\" -DCONFDIR=\"/etc/iproute2\" -D_GNU_SOURCE -D_FILE_OFFSET_BITS=64 -D_LARGEFILE_SOURCE -D_LARGEFILE64_SOURCE  -DHAVE_SETNS -DHAVE_ELF -DCONFIG_GACT -DCONFIG_GACT_PROB -DIPT_LIB_DIR=\"/lib/xtables\" -DYY_NO_INPUT   -c -o m_ipt.o m_ipt.c
In file included from ../include/iptables.h:5:0,
                 from m_ipt.c:17:
../include/xtables.h:34:29: fatal error: xtables-version.h: No such file or directory
 #include <xtables-version.h>
