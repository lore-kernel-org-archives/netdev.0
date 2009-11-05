From: Max Kellermann <mk@cm4all.com>
Subject: Re: [PATCH] tcp: set SPLICE_F_NONBLOCK after first buffer has been
	spliced
Date: Thu, 5 Nov 2009 14:23:52 +0100
Message-ID: <20091105132352.GA14453@rabbit.intern.cm-ag>
References: <20091105095947.32131.99768.stgit@rabbit.intern.cm-ag> <4AF2A929.3000201@gmail.com> <20091105105749.GA4901@rabbit.intern.cm-ag> <4AF2B551.6010302@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, jens.axboe@oracle.com,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.homepagix.de ([91.199.241.131]:56251 "EHLO fry.cm4all.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755759AbZKENXn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Nov 2009 08:23:43 -0500
Received: from localhost (unknown [127.0.0.1])
	by fry.cm4all.net (Postfix) with ESMTP id BFD7A1C00096
	for <netdev@vger.kernel.org>; Thu,  5 Nov 2009 14:23:47 +0100 (CET)
Received: from fry.cm4all.net ([127.0.0.1])
	by localhost (fry.cm4all.net [127.0.0.1]) (amavisd-new, port 10024)
	with LMTP id UxkZ7gEOHPYq for <netdev@vger.kernel.org>;
	Thu,  5 Nov 2009 14:23:47 +0100 (CET)
Received: from zero.intern.cm-ag (unknown [172.30.16.10])
	by fry.cm4all.net (Postfix) with SMTP id 93D401C00093
	for <netdev@vger.kernel.org>; Thu,  5 Nov 2009 14:23:47 +0100 (CET)
Content-Disposition: inline
In-Reply-To: <4AF2B551.6010302@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2009/11/05 12:21, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> Max Kellermann a =E9crit :
> > Do you think that a splice() should block if the socket is readable
> > and the pipe is writable according to select()?
> >=20
>=20
> Yes, this is perfectly legal
>=20
> select() can return "OK to write on fd",
> and still, write(fd, buffer, 10000000) is supposer/allowed to block i=
f fd is not O_NDELAY

=46rom the select() manpage: "those in writefds will be watched to see
if a write will not block"

=46rom the poll() manpage: "Writing now will not block."

This looks unambiguous to me, and contradicts with your thesis.  Can
you provide sources?

What is your interpretation of the guarantees provided by select() and
poll()?  Which byte count is "ok" to write after POLLOUT, and how much
is "too much"?  How does the application know?

> Please read recent commit on this area and why I think your patch
> conflicts with this commit.

I understand your patch, but I don't understand the conflict with my
patch.  Can you describe a breakage caused by my patch?
