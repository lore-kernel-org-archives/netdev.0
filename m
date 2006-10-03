From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 1/4]: Spidernet stop queue when queue is full
Date: Wed, 4 Oct 2006 00:19:42 +0200
Message-ID: <200610040019.43028.arnd@arndb.de>
References: <20061003205240.GE4381@austin.ibm.com> <20061003205729.GF4381@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@osdl.org, jeff@garzik.org, netdev@vger.kernel.org,
	James K Lewis <jklewis@us.ibm.com>,
	linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.171]:4556 "EHLO
	moutng.kundenserver.de") by vger.kernel.org with ESMTP
	id S1030610AbWJCWTz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Oct 2006 18:19:55 -0400
To: Linas Vepstas <linas@austin.ibm.com>
In-Reply-To: <20061003205729.GF4381@austin.ibm.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 03 October 2006 22:57, Linas Vepstas wrote:
> +=A0=A0=A0=A0=A0=A0=A0if ((chain->head->next =3D=3D chain->tail->prev=
) ||
> +=A0=A0=A0=A0=A0=A0=A0 =A0 (spider_net_get_descr_status(descr) !=3D S=
PIDER_NET_DESCR_NOT_IN_USE)) {
> =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0result =3D NETDEV_TX_=
LOCKED;
> =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0goto out;
> =A0=A0=A0=A0=A0=A0=A0=A0}

=2E..

> =A0out:
> -=A0=A0=A0=A0=A0=A0=A0netif_wake_queue(netdev);
> +=A0=A0=A0=A0=A0=A0=A0card->netdev_stats.tx_dropped++;
> +=A0=A0=A0=A0=A0=A0=A0netif_stop_queue(netdev);
> =A0=A0=A0=A0=A0=A0=A0=A0return result;
> =A0}

Hmm, this looks a little strange to me. I would assume that we should n=
ot
stop the queue when the device is locked, but only when it is busy.

I would assume though that the fix is to return NETDEV_TX_BUSY instead
of NETDEV_TX_LOCKED in the case above, while the netif_stop_queue()
is correct here.

	Arnd <><
