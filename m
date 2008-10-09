From: David Miller <davem@davemloft.net>
Subject: Re: NAPI enabled driver (tg3) silent packet loss ?
Date: Thu, 09 Oct 2008 11:47:09 -0700 (PDT)
Message-ID: <20081009.114709.102722304.davem@davemloft.net>
References: <efa8e58e0810091053s4b1d25b7u621ee92be84d2041@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: rvsjoen@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44027
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753407AbYJISrd convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Oct 2008 14:47:33 -0400
In-Reply-To: <efa8e58e0810091053s4b1d25b7u621ee92be84d2041@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Rune V. Sj=F8en" <rvsjoen@gmail.com>
Date: Thu, 9 Oct 2008 19:53:45 +0200

[ netdev@vger.kernel.org is the place to discuss networking
  things ]

> I am sending frames to a host using, all the frames are accounted for
> in the rx_ucast_packets counter of the device.
> However the application shows a substantial packet loss. I assume tha=
t
> the rx_ucast_packets counter is incremented when the frame is receive=
d
> and then it is put into the ring buffer. I am having a hard time
> figuring out where these packets are lost, and my suspicion lies with
> the NAPI enabled tg3.
>=20
> If the ring buffer overflows will the driver overwrite/drop packets
> without incrementing any counters ? That would explain why the packet=
s
> are counted as received and then lost (by not being passed to the nex=
t
> layer).

No, the generic device dropped counter will increment, or the
device specific RX ring full condition will be indicated.

You can also check if the networking stack itself is dropping
the packet, using netstat -s and friends.
