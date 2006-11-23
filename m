From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [take25 1/6] kevent: Description.
Date: Thu, 23 Nov 2006 14:55:04 +0300
Message-ID: <20061123115504.GB20294@2ka.mipt.ru>
References: <11641265982190@2ka.mipt.ru> <4564E2AB.1020202@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, Andrew Morton <akpm@osdl.org>,
	netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>,
	Christoph Hellwig <hch@infradead.org>,
	Chase Venters <chase.venters@clientec.com>,
	Johann Borck <johann.borck@densedata.com>,
	linux-kernel@vger.kernel.org, Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:32195 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1757028AbWKWL4V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Nov 2006 06:56:21 -0500
To: Ulrich Drepper <drepper@redhat.com>
Content-Disposition: inline
In-Reply-To: <4564E2AB.1020202@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 22, 2006 at 03:52:11PM -0800, Ulrich Drepper (drepper@redha=
t.com) wrote:
> Evgeniy Polyakov wrote:
> >+ struct kevent_ring
> >+ {
> >+   unsigned int ring_kidx, ring_uidx, ring_over;
> >+   struct ukevent event[0];
> >+ }
> >+ [...]
> >+ring_uidx - index of the first entry userspace can start reading fr=
om
>=20
> Do we need this value in the structure?  Userlevel cannot and should =
not=20
> be able to modify it.  So, userland has in any case to track the tail=
=20
> pointer itself.  Why then have this value at all?
>=20
> After kevent_init() the tail pointer is implicitly assumed to be 0.=20
> Since the front pointer (well index) is also zero nothing is availabl=
e=20
> for reading.

uidx is an index, starting from which there are unread entries. It is
updated by userspace when it commits entries, so it is 'consumer'
pointer, while kidx is an index where kernel will put new entries, i.e.
'producer' index. We definitely need them both.
Userspace can only update (implicitly by calling kevent_commit()) uidx.

> --=20
> =E2=9E=A7 Ulrich Drepper =E2=9E=A7 Red Hat, Inc. =E2=9E=A7 444 Castro=
 St =E2=9E=A7 Mountain View,=20
> CA =E2=9D=96

--=20
	Evgeniy Polyakov
