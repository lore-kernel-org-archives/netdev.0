From: Jeff Sipek <jeffpc@optonline.net>
Subject: Re: [PATCH - RFC] [1/5] 64-bit network statistics - generic net
Date: Fri, 04 Jul 2003 13:57:19 -0400
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <200307041357.32871.jeffpc@optonline.net>
References: <200307032231.39842.jeffpc@optonline.net>
 <20030704094745.GG29233@lug-owl.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 7BIT
Cc: Andrew Morton <akpm@digeo.com>,
	Dave Jones <davej@codemonkey.org.uk>,
	Jeff Garzik <jgarzik@pobox.com>, netdev@oss.sgi.com,
	Linus Torvalds <torvalds@osdl.org>
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
In-reply-to: <20030704094745.GG29233@lug-owl.de>
To: Jan-Benedict Glaw <jbglaw@lug-owl.de>,
	Kernel Mailing List <linux-kernel@vger.kernel.org>
Content-Disposition: inline
Content-description: clearsigned data
List-Id: netdev.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

On Friday 04 July 2003 05:47, Jan-Benedict Glaw wrote:
<snip>
> Well... I don't really like to break userspace, but why don't we simply
> make packet/traffic counters long long / u_int64_t? This way, we'd
> simply keep almost all drivers untouched and only need to fiddle with
> some sprints()/printk() statements?

I'm no hardware expert, however, that approach contains potential race 
condition - not a system critical one, but something we should be concerned 
about. If one cpu tries to read a u_int64_t variable while another tries to 
update it, the worst case scenario is that the reader will get the high 
32-bits before the write, and low 32-bit after the write, now if the counter 
overflow, the number would be off by 4GB! (This only applies to 32-bit 
architectures.) True, there are cache coherency algorithms, etc...

> Really, how many programs use the current statistics? I'd prefer to
> modify them over adding strange patches like this one to the kernel...

I believe that on any kind of router some at some point in time would like to 
know the data transfered.

Jeff.

- -- 
Keyboard not found!
Press F1 to enter Setup
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.2 (GNU/Linux)

iD8DBQE/BcADwFP0+seVj/4RAq2TAKDS0oAnj0/PrCuPoxdQF0euBiy6LACeMHqk
gWJhwub4y0VtQmC/hcevJB4=
=RCSe
-----END PGP SIGNATURE-----
