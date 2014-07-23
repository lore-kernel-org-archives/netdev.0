From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] dp83640: Fix receive timestamp race
 condition
Date: Tue, 22 Jul 2014 19:57:20 -0700 (PDT)
Message-ID: <20140722.195720.2254769990435787100.davem@davemloft.net>
References: <1406035245-31091-1-git-send-email-stefan.sorensen@spectralink.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: richardcochran@gmail.com, netdev@vger.kernel.org
To: stefan.sorensen@spectralink.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54032 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755250AbaGWC5V convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2014 22:57:21 -0400
In-Reply-To: <1406035245-31091-1-git-send-email-stefan.sorensen@spectralink.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Stefan S=F8rensen <stefan.sorensen@spectralink.com>
Date: Tue, 22 Jul 2014 15:20:45 +0200

> When timestamping received packets, rx_timestamp_work may be schedule=
d
> before the timestamps is received from the hardware resulting in the
> packet beeing delivered without the timestamp.
>=20
> This is fixed by changing the receive timestamp path:
>=20
> On receiving a packet that need timestamping, the rxts list is
> traversed.  If a match is found, packet+timestamp are delivered,
> otherwise the packet is added to a rx_queue.
>=20
> When a timestamp arrives rx_queue is traversed and if a matching
> packet is found, it is delivered with the timestamp. Otherwise the
> timestamp is added to the rxts list for matching with packets arrivin=
g
> later.
>=20
> In case the hardware drops a timestamp, a workqueue regularly checks
> the queue for old packets and delivers them without a timestamp.
>=20
> Signed-off-by: Stefan S=F8rensen <stefan.sorensen@spectralink.com>

Applied.
