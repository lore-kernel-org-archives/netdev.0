From: Ulrich Drepper <drepper@redhat.com>
Subject: Re: Kevent POSIX timers support.
Date: Mon, 27 Nov 2006 10:36:06 -0800
Message-ID: <456B3016.9020706@redhat.com>
References: <456603E7.9090006@redhat.com>	<20061124095052.GC13600@2ka.mipt.ru>	<456B2C82.7040700@redhat.com> <20061127.102443.74556125.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: johnpol@2ka.mipt.ru, akpm@osdl.org, netdev@vger.kernel.org,
	zach.brown@oracle.com, hch@infradead.org,
	chase.venters@clientec.com, johann.borck@densedata.com,
	linux-kernel@vger.kernel.org, jeff@garzik.org, aviro@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:26272 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S933060AbWK0Sgp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Nov 2006 13:36:45 -0500
To: David Miller <davem@davemloft.net>
In-Reply-To: <20061127.102443.74556125.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> Now we'll have to have a compat layer for 32-bit/64-bit environments
> thanks to POSIX timers, which is rediculious.

We already have compat_sys_timer_create.  It should be sufficient just=20
to add the conversion (if anything new is needed) there.  The pointer=20
value can be passed to userland in one or two int fields, I don't reall=
y=20
care.  When reporting the event to the user code we cannot just point=20
into the ring buffer anyway.  So while copying the data we can rewrite=20
it if necessary.  I see no need to complicate the code more than it=20
already is.

--=20
=E2=9E=A7 Ulrich Drepper =E2=9E=A7 Red Hat, Inc. =E2=9E=A7 444 Castro S=
t =E2=9E=A7 Mountain View, CA =E2=9D=96
