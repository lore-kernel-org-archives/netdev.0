From: David Miller <davem@davemloft.net>
Subject: Re: BSD 4.2 style TCP keepalives
Date: Wed, 06 Jan 2010 16:59:33 -0800 (PST)
Message-ID: <20100106.165933.226786062.davem@davemloft.net>
References: <20100106.002328.141253811.davem@davemloft.net>
	<20100106.150453.186399201.davem@davemloft.net>
	<alpine.DEB.2.00.1001070231540.26362@melkinpaasi.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, nhorman@tuxdriver.com
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38557
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932814Ab0AGA71 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Jan 2010 19:59:27 -0500
In-Reply-To: <alpine.DEB.2.00.1001070231540.26362@melkinpaasi.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Thu, 7 Jan 2010 02:34:51 +0200 (EET)

> On Wed, 6 Jan 2010, David Miller wrote:
>=20
>> 3) tcp_data_queue() should make it to, and hit, this conditional:
>>=20
>> 	if (!after(TCP_SKB_CB(skb)->end_seq, tp->rcv_nxt)) {
>>=20
>>    which will schedule an ACK the same exact way we would if
>>    tcp_sequence() rejected the sequence range.
>>=20
>> So it's a mystery why we aren't responding to Windows 2000's
>> BSD 4.2 style zero window probes.
>>=20
>> Can someone please validate my analysis?
>=20
> In 3) I don't see why we'd hit that one as peer's snd_una+1 would be=20
> larger than rcv_nxt.

Peer constructs keepalive packet using sequence [snd.una-1,snd.una],
both of which are <=3D rcv_nxt
