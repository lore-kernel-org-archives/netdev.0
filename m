From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Subject: Re: [PATCH 1/7] CAN: Allocate protocol numbers for PF_CAN
Date: Tue, 2 Oct 2007 11:43:54 -0300
Message-ID: <20071002144354.GH7881@ghostprotocols.net>
References: <20071002131006.31727.0@janus.isnogud.escape.de> <20071002131107.31727.1@janus.isnogud.escape.de> <20071002141138.GD7881@ghostprotocols.net> <ygf7im5h9r7.fsf@janus.isnogud.escape.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	Oliver Hartkopp <oliver@hartkopp.net>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>
To: Urs Thuermann <urs@isnogud.escape.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.172]:58939 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752252AbXJBOoL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Oct 2007 10:44:11 -0400
Received: by ug-out-1314.google.com with SMTP id z38so2120153ugc
        for <netdev@vger.kernel.org>; Tue, 02 Oct 2007 07:44:10 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <ygf7im5h9r7.fsf@janus.isnogud.escape.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Em Tue, Oct 02, 2007 at 04:27:40PM +0200, Urs Thuermann escreveu:
> Arnaldo Carvalho de Melo <acme@ghostprotocols.net> writes:
> 
> > > --- net-2.6.24.orig/include/linux/if_arp.h	2007-10-02 12:10:51.000000000 +0200
> > > +++ net-2.6.24/include/linux/if_arp.h	2007-10-02 12:11:01.000000000 +0200
> > > @@ -52,6 +52,7 @@
> > >  #define ARPHRD_ROSE	270
> > >  #define ARPHRD_X25	271		/* CCITT X.25			*/
> > >  #define ARPHRD_HWX25	272		/* Boards with X.25 in firmware	*/
> > > +#define ARPHRD_CAN	280		/* Controller Area Network      */
> > 
> > Is 280 used in other OS? Just curious as why not using 273
> 
> When we first implemented PF_CAN a couple of years ago, we wanted to
> avoid a clash with other ARPHRD_* defines which might be added, so we
> skipped some numbers after the last used one.  I don't care what
> number ARPHRD_CAN is, we can use 273.
> 
> > > --- net-2.6.24.orig/include/linux/socket.h	2007-10-02 12:10:51.000000000 +0200
> > > +++ net-2.6.24/include/linux/socket.h	2007-10-02 12:11:01.000000000 +0200
> > > @@ -185,6 +185,7 @@
> > >  #define AF_PPPOX	24	/* PPPoX sockets		*/
> > >  #define AF_WANPIPE	25	/* Wanpipe API Sockets */
> > >  #define AF_LLC		26	/* Linux LLC			*/
> > > +#define AF_CAN		29	/* Controller Area Network      */
> > 
> > Ditto
> > 
> > >  #define AF_TIPC		30	/* TIPC sockets			*/
> > >  #define AF_BLUETOOTH	31	/* Bluetooth sockets 		*/
> > >  #define AF_IUCV		32	/* IUCV sockets			*/
> 
> For the same reason as above, we didn't use 27, but the last unused
> without modifying AF_MAX.  First, we had AF_CAN == 30, then TIPC used
> that number and we changed AF_CAN to 29.  Changing again would mean an
> ABI change and would break user apps.  If there is a pressing reason I
> wouldn't mind personally, but it would probably upset quite a number
> of users of our code.  It seems common now to allocate these numbers
> from the top in decreasing order.

Not a problem to have the hole, eventually we'll find something to put
there.

As I said, just curiosity, but can you see a AF_NETBEUI implementation
around? I'm just joking, but you could have reserved it and avoided the
clash with TIPC (that I don't remember if has made any reservation).

Protocol number allocation with collision detection is worse than doing
avoidance 8-)

- Arnaldo
