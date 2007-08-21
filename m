From: Pavel Machek <pavel@ucw.cz>
Subject: Re: ATA over ethernet swapping
Date: Tue, 21 Aug 2007 09:42:01 +0200
Message-ID: <20070821074201.GC7258@elf.ucw.cz>
References: <20070731135831.GA4604@elf.ucw.cz> <20070731150324.GE3206@coraid.com> <20070731152924.GM2087@elf.ucw.cz> <20070731162140.GI3206@coraid.com> <20070731222742.GR2087@elf.ucw.cz> <1185959909.12034.38.camel@twins> <20070809101105.GA7581@elf.ucw.cz> <1186991157.20108.47.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Ed L. Cashin" <ecashin@coraid.com>,
	kernel list <linux-kernel@vger.kernel.org>, ak@suse.de,
	Netdev list <netdev@vger.kernel.org>
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gprs189-60.eurotel.cz ([160.218.189.60]:55088 "EHLO amd.ucw.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754453AbXHUJeK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Aug 2007 05:34:10 -0400
Content-Disposition: inline
In-Reply-To: <1186991157.20108.47.camel@twins>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi!

> > But I'm able to compile kernel (-j 10) on 128MB machine, and I tried
> > cat /dev/zero | grep foo to exhaust memory... and could not reproduce
> > the deadlock. Should I pingflood? Tweak down ammount of atomic memory
> > avaialable to make deadlocks easier to reproduce?
> 
> I usually test swap over NFS in the following manner, I setup a regular
> inet service on the machine (apache or a bunch of ncat sockets piping to
> files or something) and run a heavy workload on the machine (128M):
> 2*64M file backed thrashers and 2*64M anonymous thrashers. Then I start
> clients for the regular inet service, wait for a bit, and shut down the
> NFS server.
> 
> This makes the machine grind to a halt, I then restart the NFS server,
> wait for it to reconnect and the client to come alive again.
> 
> Without the last few swap-over-NFS patches this last bit - getting back
> out of that situation - never happens.
> 
> The basic idea is to make connectivity to the machine where swap traffic
> goes very hard (pull a cable, cleanly shut down the server) and to keep
> other network traffic pounding the machine.

Hmm, I could not get swap-over-ata-over-ethernet to break. Maybe I
should not have local / filesystem, because it allows kernel to get
rid of some memory pressure by dropping clean pages? Plus I guess
ata-over-ethernet has some significant advantages, as it works over
ethernet directly, not over IP.

								Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
