From: Donald Becker <becker@scyld.com>
Subject: Re: Is a driver allowed to modify dev->flags?
Date: Tue, 1 Apr 2003 12:26:53 -0500 (EST)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <Pine.LNX.4.44.0304011213380.1685-100000@beohost.scyld.com>
References: <3e89c32348ce76.94538914@not right>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-net@vger.kernel.org, <netdev@oss.sgi.com>
Return-path: <linux-net-owner@vger.kernel.org>
To: Rask Ingemann Lambertsen <rask@sygehus.dk>
In-Reply-To: <3e89c32348ce76.94538914@not right>
List-Id: netdev.vger.kernel.org

On Tue, 1 Apr 2003, Rask Ingemann Lambertsen wrote:

> Is a network device driver allowed to modify dev->flags? For example:
> 
> if (dev->flags & IFF_ALLMULTI)
>         dev->flags |= IFF_PROMISC;

You must be looking at the atp.c driver, or a driver that cribbed from
it.  (Is anyone still running a parallel port Ethernet device?!)

Alan Cox added this code to atp.c because the chip doesn't have a
reasonable multicast filter.  The only way to receive all multicast
traffic was to turn on promiscuous mode.  But that caused a problem
with some parts of the protocol stack were passed traffic not intended
for the local host.

A better solution (which is usually easier to see later) is to have
the driver do the trivial final packet filtering itself.

> I've found it to cause the IFF_PROMISC flag to stick when using
> "tcpdump -p", which to my surprice sets the IFF_ALLMULTI flag. 

Which driver are you using?

-- 
Donald Becker				becker@scyld.com
Scyld Computing Corporation		http://www.scyld.com
410 Severn Ave. Suite 210		Scyld Beowulf cluster system
Annapolis MD 21403			410-990-9993

