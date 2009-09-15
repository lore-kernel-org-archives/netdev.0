From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH RFC] tun: export underlying socket
Date: Tue, 15 Sep 2009 16:18:39 +0300
Message-ID: <20090915131839.GA6534@redhat.com>
References: <20090910125929.GA32593@redhat.com> <15ddcffd0909140107m4d94f5abh5405074b654bd15d@mail.gmail.com> <20090914080923.GC14030@redhat.com> <4AADFC0A.30305@voltaire.com> <20090914091151.GE14030@redhat.com> <4AAE1026.4090702@voltaire.com> <20090914101012.GA14176@redhat.com> <4AAE4DFC.9080500@voltaire.com> <20090914154011.GB3556@redhat.com> <15ddcffd0909150611s2e172f19xa8abe794abf13159@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Or Gerlitz <ogerlitz@voltaire.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59858 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752731AbZIONX4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Sep 2009 09:23:56 -0400
Content-Disposition: inline
In-Reply-To: <15ddcffd0909150611s2e172f19xa8abe794abf13159@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 15, 2009 at 04:11:22PM +0300, Or Gerlitz wrote:
> On 9/14/09, Michael S. Tsirkin <mst@redhat.com> wrote:
> >> 3. for tun fd
> >> VM.TX is translated by vhost to sendmsg which is translated by tun=
 to
> >> netif_rx which is then handled by the bridge
> >> NIC RX=A0=A0goes to the bridge which xmits the packet a tun interf=
ace, now
> >> what makes tun provide this packet to vhost and how it is done?
>=20
> > Same as above. vhost polls tun and calls recvmsg on the socket
>=20
> no, correct if I'm wrong, but recvmsg calls tun_do_read and the later
> calls tun_put_user to the packet goes to user space and not into the =
virtq
>=20
> Or.

It ends up in the virtq because that maps userspace addresses.
This is the same as with packet sockets, really.

--=20
MST
