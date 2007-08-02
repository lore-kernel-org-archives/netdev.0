From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: NETPOLL=y , NETDEVICES=n compile error ( Re: 2.6.23-rc1-mm1 )
Date: Thu, 2 Aug 2007 13:40:42 +0200
Message-ID: <20070802114042.GB1699@ff.dom.local>
References: <20070731083210.GA1797@ff.dom.local> <46AF0B8C.7070006@googlemail.com> <20070731121735.GA1046@ff.dom.local> <46AF4F9C.5060000@googlemail.com> <20070801095920.GA1941@ff.dom.local> <20070802020219.GM11166@waste.org> <20070802093659.GB27748@uranus.ravnborg.org> <alpine.LFD.0.999.0708021547420.8258@enigma.security.iitk.ac.in>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sam Ravnborg <sam@ravnborg.org>, Matt Mackall <mpm@selenic.com>,
	Gabriel C <nix.or.die@googlemail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jason.wessel@windriver.com, amitkale@linsyssoft.com
To: Satyam Sharma <satyam@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx12.go2.pl ([193.17.41.142]:48470 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752108AbXHBLbM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Aug 2007 07:31:12 -0400
Content-Disposition: inline
In-Reply-To: <alpine.LFD.0.999.0708021547420.8258@enigma.security.iitk.ac.in>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 02, 2007 at 04:02:21PM +0530, Satyam Sharma wrote:
> Hi,
> 
> 
> On Thu, 2 Aug 2007, Sam Ravnborg wrote:
> 
> > > > 
> > > > ...
> > > > endif # NETDEVICES
> > > > 
> > > > config NETPOLL
> > > >         depends on NETDEVICES
> > > >         def_bool NETCONSOLE
> > > > 
> > > > config NETPOLL_TRAP
> > > >         bool "Netpoll traffic trapping"
> > > >         default n
> > > >         depends on NETPOLL
> > > > 
> > > > config NET_POLL_CONTROLLER
> > > >         def_bool NETPOLL
> > > >         depends on NETPOLL
> > > > 
> > > > 
> > > > seems to select NET_POLL_CONTROLLER after selecting NETPOLL, but
> > > > still doesn't check for NETDEVICES dependency.
> > > 
> > > That's odd. Adding Sam to the cc:.
> 
> I just noticed this thread, but I wonder what the fuss is all
> about :-) Kconfig dependencies are easy, really -- any code that
> pulls in code from elsewhere, must explicitly "depends on" it.
> It is possible to use "select" as well, but could lead to breakages
> as discussed to death on at least 64592 other threads on LKML already
> and hence should only be used for library-like code that does not
> have any dependencies itself.

So, it seems at least one time not enough (or maybe it would be better
to write this 1 time only, but in Documentation/).

> 
> 
> > select is evil....
> > select will by brute force set a symbol equal to 'y' without
> > visiting the dependencies.
> > So abusing select you are able to select a symbol FOO even 
> > if FOO depends on BAR that is not set.
> > 
> > In general use select only for non-visible symbols (no promts anywhere)
> > and for symbols with no dependencies.
> > That will limit the suefullness but on the other hand avoid the illegal
> > configurations all over.
> 
> The problem with using "depends on" is that your config symbol becomes
> invisible unless the dependency has already been selected.
> 
> So, there's a workaround: make the ultimate config symbol itself depend
> upon the grand-dependency (excuse the nomenclature) and just "select"
> the immediate-parent-dependency, i.e. the following:
> 
> CONFIG_BAZ
> 	...
> 
> CONFIG BAR
> 	depends on BAZ
> 
> CONFIG_FOO
> 	depends on BAZ
> 	select BAR
> 
> is perfectly legal, and doesn't cause any build problems. Perhaps such a
> solution makes sense here as well?
> 
> 
> > kconfig should one day warn about such things but I have not fel inclined
> > to dive into the matters hoping that Roman does one day.
> 
> Yup, I've wanted to do this myself, in fact I wanted to implement an idea
> I had in mind ( http://lkml.org/lkml/2007/5/16/257 ) but for some reason
> I tend to stay away from stuff in scripts/ :-)

How often "common" developer has to make such decisions in Kconfig?
Probably no more than once per year. So, it's fair to blame anybody
for not reading lkml to find if there are some bugs or
recommendations before using apparently simple tool? I think there
is usually some README for such things (maybe in Documentation/)?

Thanks,
Jarek P.

PS: if it's so easy and it's enough to read only 64592 lkml messages,
I wonder why Andrew, who knows all lkml, and reads more messages per
hour, cared to remember mainly one short conclusion...
