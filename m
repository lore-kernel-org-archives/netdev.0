From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: [RFC][PATCH 0/3] TCP/IP Critical socket communication mechanism
Date: Thu, 15 Dec 2005 14:07:50 +0100
Message-ID: <1134652070.16486.44.camel@laptopd505.fenrus.org>
References: <Pine.LNX.4.58.0512140042280.31720@w-sridhar.beaverton.ibm.com>
	 <9a8748490512141216x7e25ca2cucb675f11f0c9d913@mail.gmail.com>
	 <43A08546.8040708@superbug.co.uk> <20051215015456.GC23393@gaz.sfgoth.com>
	 <43A155AE.4050105@superbug.co.uk>
	 <1134647248.16486.37.camel@laptopd505.fenrus.org>
	 <1134651635.5912.108.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: James Courtier-Dutton <James@superbug.co.uk>,
	Mitchell Blank Jr <mitch@sfgoth.com>,
	Jesper Juhl <jesper.juhl@gmail.com>,
	Sridhar Samudrala <sri@us.ibm.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1422713AbVLONIF@vger.kernel.org>
To: hadi@cyberus.ca
In-Reply-To: <1134651635.5912.108.camel@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2005-12-15 at 08:00 -0500, jamal wrote:
> On Thu, 2005-15-12 at 12:47 +0100, Arjan van de Ven wrote:
> > > 
> > > You are using the wrong hammer to crack your nut.
> > > You should instead approach your problem of why the ARP entry gets lost.
> > > For example, you could give as critical priority to your TCP session, 
> > > but that still won't cure your ARP problem.
> > > I would suggest that the best way to cure your arp problem, is to 
> > > increase the time between arp cache refreshes.
> > 
> > or turn it around entirely: all traffic is considered important
> > unless... and have a bunch of non-critical sockets (like http requests)
> > be marked non-critical.
> 
> The big hole punched by DaveM is that of dependencies: a http tcp
> connection is tied to ICMP or the IPSEC example given; so you need a lot
> more intelligence than just what your app is knowledgeable about at its
> level. 

yeah well sort of. You're right of course, but that also doesn't mean
you can't give hints from the other side. Like "data for this socked is
NOT critical important". It gets tricky if you only do it for OOM stuff;
because then that one ACK packet could cause a LOT of memory to be
freed, and as such can be important for the system even if the socket
isn't.
