From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] loopback: better handling of packet drops
Date: Fri, 17 Apr 2009 14:22:30 +0200
Message-ID: <49E87486.7090901@cosmosbay.com>
References: <49E84B99.1080502@cosmosbay.com>	<49E854A4.1010204@cosmosbay.com>	<49E85AFD.6080407@cosmosbay.com> <20090417.035112.171173490.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:57478 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753384AbZDQMWi convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Apr 2009 08:22:38 -0400
In-Reply-To: <20090417.035112.171173490.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Fri, 17 Apr 2009 12:33:33 +0200
>=20
>> Splitting netif_rx() with a helper function boosts tbench
>> performance by 1%, because we can avoid two tests (about netpoll and
>> timestamping)
>=20
> Loopback is not a special device no matter how much you wish
> it might be :-)
>=20
> This is why I haven't really pursued any further those patches I
> showed you that treat local TCP connections specially, it just had th=
e
> realy possibility to break clever things people might be doing over
> loopback using the packet scheduler classifier and packet scheduler
> actions.

Point taken.

>=20
> I also think it is valid to use netpoll over loopback, especially for
> testing.

Oh I didnt knew it was possible/useful, sorry about that.

>=20
> So please undo this part of the patch.  You always try to combine
> multiple distinct changes, and I would have taken just your TX drop
> change if you hadn't added this __netif_rx() stuff to it :-(

I followed on this patch to show what I had in mind, and why
I thought it was a transmit error more than a receive one.

1) Do you reject idea of splitting netif_rx() to be able to
   not freeing skb in case of congestion ?
2) If not, do you want me to send two separate patches ?
3) Should I update rx_errors or tx_errors or both ?


Thank you

