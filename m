From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: NETPOLL=y , NETDEVICES=n compile error ( Re: 2.6.23-rc1-mm1 )
Date: Thu, 2 Aug 2007 11:36:59 +0200
Message-ID: <20070802093659.GB27748@uranus.ravnborg.org>
References: <20070731083210.GA1797@ff.dom.local> <46AF0B8C.7070006@googlemail.com> <20070731121735.GA1046@ff.dom.local> <46AF4F9C.5060000@googlemail.com> <20070801095920.GA1941@ff.dom.local> <20070802020219.GM11166@waste.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jarek Poplawski <jarkao2@o2.pl>,
	Gabriel C <nix.or.die@googlemail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jason.wessel@windriver.com, amitkale@linsyssoft.com
To: Matt Mackall <mpm@selenic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pasmtpa.tele.dk ([80.160.77.114]:58924 "EHLO pasmtpA.tele.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751606AbXHBJfo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Aug 2007 05:35:44 -0400
Content-Disposition: inline
In-Reply-To: <20070802020219.GM11166@waste.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > 
> > ...
> > endif # NETDEVICES
> > 
> > config NETPOLL
> >         depends on NETDEVICES
> >         def_bool NETCONSOLE
> > 
> > config NETPOLL_TRAP
> >         bool "Netpoll traffic trapping"
> >         default n
> >         depends on NETPOLL
> > 
> > config NET_POLL_CONTROLLER
> >         def_bool NETPOLL
> >         depends on NETPOLL
> > 
> > 
> > seems to select NET_POLL_CONTROLLER after selecting NETPOLL, but
> > still doesn't check for NETDEVICES dependency.
> 
> That's odd. Adding Sam to the cc:.

select is evil....
select will by brute force set a symbol equal to 'y' without
visiting the dependencies.
So abusing select you are able to select a symbol FOO even 
if FOO depends on BAR that is not set.

In general use select only for non-visible symbols (no promts anywhere)
and for symbols with no dependencies.
That will limit the suefullness but on the other hand avoid the illegal
configurations all over.

kconfig should one day warn about such things but I have not fel inclined
to dive into the matters hoping that Roman does one day.

	Sam
