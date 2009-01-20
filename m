From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: why usr/include/linux/if_frad.h is required
Date: Tue, 20 Jan 2009 18:47:01 +0100
Message-ID: <200901201847.03030.arnd@arndb.de>
References: <1232463174.3088.15.camel@localhost.localdomain> <1232463242.3088.16.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: mike.mclagan@linux.org, Ingo Molnar <mingo@elte.hu>,
	Sam Ravnborg <sam@ravnborg.org>, netdev@vger.kernel.org,
	davem@davemloft.net, LKML <linux-kernel@vger.kernel.org>
To: Jaswinder Singh Rajput <jaswinder@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.171]:52468 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756693AbZATRrX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2009 12:47:23 -0500
In-Reply-To: <1232463242.3088.16.camel@localhost.localdomain>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 20 January 2009, Jaswinder Singh Rajput wrote:
> CC: LKML
> 
> On Tue, 2009-01-20 at 20:23 +0530, Jaswinder Singh Rajput wrote:
> > For if_frad.h I am getting two warnings with 'make headers_check':
> >   usr/include/linux/if_frad.h:29: leaks CONFIG_DLCI to userspace where it is not valid
> >   usr/include/linux/if_frad.h:129: leaks CONFIG_DLCI to userspace where it is not valid
> > 
> > Almost all if_frad.h is covered with #if defined(CONFIG_DLCI) || defined(CONFIG_DLCI_MODULE) 
> > 
> > If I remove this portion so only this what we get in userspace:
> > 
> > #ifndef _FRAD_H_
> > #define _FRAD_H_
> > 
> > #include <linux/if.h>
> > 
> > #endif
> > 
> > So I am surprising what is the point of this ? 
> > 
> > Can I change its name to is_fraud ;-)

The CONFIG_DLCI check in there is clearly in error, the definition in there
is a user interface. The obvious solution is to drop the #if / #endif pair
without a replacement.

	Arnd <><
