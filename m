From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: dropwatch for network drop monitor
Date: Fri, 17 Apr 2009 09:28:48 -0400
Message-ID: <20090417132848.GA2723@hmsreliant.think-freely.org>
References: <200904171257.n3HCvOba029938@post.webmailer.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Oliver Hartkopp <oliver@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:49373 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751777AbZDQN25 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Apr 2009 09:28:57 -0400
Content-Disposition: inline
In-Reply-To: <200904171257.n3HCvOba029938@post.webmailer.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 17, 2009 at 02:57:24PM +0200, Oliver Hartkopp wrote:
> Hi Neal,
>=20
> i tried the dropwatch app from your git.
>=20
> Compiling the source produces:
>=20
> hartko@vwagwolkf320:~/dropwatch/src$ make
> gcc -c -g main.c
> gcc -c -g lookup.c
> gcc -c -g lookup_bfd.c
> gcc -c -g lookup_kas.c
> lookup_kas.c: In function =91lookup_kas_cache=92:
> lookup_kas.c:56: warning: cast from pointer to integer of different s=
ize
> lookup_kas.c: In function =91lookup_kas_proc=92:
> lookup_kas.c:100: warning: cast from pointer to integer of different =
size
> lookup_kas.c:103: warning: cast from pointer to integer of different =
size
> gcc -g -o dropwatch main.o lookup.o lookup_bfd.o lookup_kas.o -lbfd -=
lreadline -lnl=20
>=20
Strange, I don't get this, are you building on 32 bit or 64 bit?  Altho=
ugh,
that shouldn't cause you any problems at the moment, since that code is=
 still
not actually used.

> You cast a 'pc' variable to __u64 - is your code depending on 64 bit =
??
>=20
Not depending on, but I wanted to provide room in that data field to ho=
ld a void
pointer, so I cas't it to a __u64

> Starting the stuff brings:
>=20
> vwagwolkf320:/home/hartko/dropwatch/src# ./dropwatch=20
> Initalizing kallsyms db
> dropwatch> start
> Enabling monitoring...
> Waiting for activation ack....
> Waiting for activation ack....
> Waiting for activation ack....
> Waiting for activation ack....
> Waiting for activation ack....
> Waiting for activation ack....
> Failed activation request, error: Operation now in progress
> Shutting down ...
> vwagwolkf320:/home/hartko/dropwatch/src#=20
>=20
> And in my kernel log i get at the same time:
> [ 7070.568482] netlink: 60 bytes leftover after parsing attributes.
>=20
> Any ideas?
>=20
> Oliver
>=20
>=20
Not off the top of my head, I've run this on 64 bit and 32 bit and not =
seen
these errors.  I'll bring it back up on my 32 bit system and see what c=
omes of
it.  Do me a favor and open a bug at the trac page for this.  Thanks!
Neil

