From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: NETPOLL=y , NETDEVICES=n compile error ( Re: 2.6.23-rc1-mm1 )
Date: Thu, 2 Aug 2007 11:00:08 +0200
Message-ID: <20070802090008.GA1699@ff.dom.local>
References: <20070731083210.GA1797@ff.dom.local> <46AF0B8C.7070006@googlemail.com> <20070731121735.GA1046@ff.dom.local> <46AF4F9C.5060000@googlemail.com> <20070801095920.GA1941@ff.dom.local> <20070802020219.GM11166@waste.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Gabriel C <nix.or.die@googlemail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jason.wessel@windriver.com, amitkale@linsyssoft.com,
	Sam Ravnborg <sam@ravnborg.org>
To: Matt Mackall <mpm@selenic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:49090 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753562AbXHBIui (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Aug 2007 04:50:38 -0400
Content-Disposition: inline
In-Reply-To: <20070802020219.GM11166@waste.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 01, 2007 at 09:02:19PM -0500, Matt Mackall wrote:
> On Wed, Aug 01, 2007 at 11:59:21AM +0200, Jarek Poplawski wrote:
> > On Tue, Jul 31, 2007 at 05:05:00PM +0200, Gabriel C wrote:
> > > Jarek Poplawski wrote:
> > > > On Tue, Jul 31, 2007 at 12:14:36PM +0200, Gabriel C wrote:
> > > >> Jarek Poplawski wrote:
> > > >>> On 28-07-2007 20:42, Gabriel C wrote:
> > > >>>> Andrew Morton wrote:
> > > >>>>> On Sat, 28 Jul 2007 17:44:45 +0200 Gabriel C <nix.or.die@googlemail.com> wrote:
...
> > > >>>>>> net/core/netpoll.c:155: error: 'struct net_device' has no member named 'poll_controller'
...
> > > >>>>>> I think is because KGDBOE selects just NETPOLL.
> > > >>>>>>
> > > >>>>> Looks like it.
> > > >>>>>
> > > >>>>> Select went and selected NETPOLL and NETPOLL_TRAP but things like
> > > >>>>> CONFIG_NETDEVICES and CONFIG_NET_POLL_CONTROLLER remain unset.  `select'
> > > >>>>> remains evil.
...
> > seems to select NET_POLL_CONTROLLER after selecting NETPOLL, but
> > still doesn't check for NETDEVICES dependency.
> 
> That's odd. Adding Sam to the cc:.

Looks right, but after reading Andrew's opinion about select I'd be
astonished if he doesn't know this problem already.

> 
> > > >> Now KGDBOE just selects NETPOLL and NETPOLL_TRAP.
> > > >> Adding 'select CONFIG_NET_POLL_CONTROLLER' let kgdboe compiles but the question is does it work without any ethernet card ?
> > > > 
> > > > Why kgdboe should care what netpoll needs? So, I hope, you are adding
> > > > this select under config NETPOLL. On the other hand, if NETPOLL should
> > > > depend on NET_POLL_CONTROLLER there is probably no reason to have them
> > > > both.
> > > 
> > > NET_POLL_CONTROLLER has def_bool NETPOLL if NETDEVICES .
> > > 
> > > Net peoples ping ?:)
> 
> How about cc:ing the netpoll maintainer?

Is there a new one or do you suggest possibility of abusing the
authority of the netpoll's author with such trifles...?!

BTW, I can't find any official meaning of def_bool, but it's name
suggests only default value, so logically it should be not enough
to assure NET_POLL_CONTROLLER=y, and netpoll should use "depends",
"require" or "select" (IMHO more readable too), but on the other
hand this could be practially wrong...

>  
> > OK, I wasn't right here: there is no visible reason for both in the
> > kernel code, but I can imagine there could be some external users of
> > NET_POLL_CONTROLLER without NETPOLL.
> 
> I don't know of any. As far as I can tell at this point,
> NET_POLL_CONTROLLER == NETPOLL.

There are some notions about "other diagnostic tools" in some
net drivers, eg. 3c509.c, so there would be a little bit of
work if, after changing this, they really exist (and even if
not - maybe it's reasonable to save such possibility for the
future?).

Best regards,
Jarek P.
