From: Urs Thuermann <urs@isnogud.escape.de>
Subject: Re: [PATCH 1/7] CAN: Allocate protocol numbers for PF_CAN
Date: 02 Oct 2007 16:27:40 +0200
Message-ID: <ygf7im5h9r7.fsf@janus.isnogud.escape.de>
References: <20071002131006.31727.0@janus.isnogud.escape.de>
	<20071002131107.31727.1@janus.isnogud.escape.de>
	<20071002141138.GD7881@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	Oliver Hartkopp <oliver@hartkopp.net>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>
To: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from oker.escape.de ([194.120.234.254]:56113 "EHLO oker.escape.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751733AbXJBOaz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Oct 2007 10:30:55 -0400
In-Reply-To: <20071002141138.GD7881@ghostprotocols.net>; from Arnaldo Carvalho de Melo on Tue, 2 Oct 2007 11:11:38 -0300
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arnaldo Carvalho de Melo <acme@ghostprotocols.net> writes:

> > --- net-2.6.24.orig/include/linux/if_arp.h	2007-10-02 12:10:51.000000000 +0200
> > +++ net-2.6.24/include/linux/if_arp.h	2007-10-02 12:11:01.000000000 +0200
> > @@ -52,6 +52,7 @@
> >  #define ARPHRD_ROSE	270
> >  #define ARPHRD_X25	271		/* CCITT X.25			*/
> >  #define ARPHRD_HWX25	272		/* Boards with X.25 in firmware	*/
> > +#define ARPHRD_CAN	280		/* Controller Area Network      */
> 
> Is 280 used in other OS? Just curious as why not using 273

When we first implemented PF_CAN a couple of years ago, we wanted to
avoid a clash with other ARPHRD_* defines which might be added, so we
skipped some numbers after the last used one.  I don't care what
number ARPHRD_CAN is, we can use 273.

> > --- net-2.6.24.orig/include/linux/socket.h	2007-10-02 12:10:51.000000000 +0200
> > +++ net-2.6.24/include/linux/socket.h	2007-10-02 12:11:01.000000000 +0200
> > @@ -185,6 +185,7 @@
> >  #define AF_PPPOX	24	/* PPPoX sockets		*/
> >  #define AF_WANPIPE	25	/* Wanpipe API Sockets */
> >  #define AF_LLC		26	/* Linux LLC			*/
> > +#define AF_CAN		29	/* Controller Area Network      */
> 
> Ditto
> 
> >  #define AF_TIPC		30	/* TIPC sockets			*/
> >  #define AF_BLUETOOTH	31	/* Bluetooth sockets 		*/
> >  #define AF_IUCV		32	/* IUCV sockets			*/

For the same reason as above, we didn't use 27, but the last unused
without modifying AF_MAX.  First, we had AF_CAN == 30, then TIPC used
that number and we changed AF_CAN to 29.  Changing again would mean an
ABI change and would break user apps.  If there is a pressing reason I
wouldn't mind personally, but it would probably upset quite a number
of users of our code.  It seems common now to allocate these numbers
from the top in decreasing order.

urs
