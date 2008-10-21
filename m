From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] sky2: skb recycling
Date: Tue, 21 Oct 2008 13:38:11 -0700
Message-ID: <20081021133811.68bd5ce1@extreme>
References: <20081020190922.7dd6510a@extreme>
	<20081020.221857.209830018.davem@davemloft.net>
	<48FE34AF.8050508@hp.com>
	<48FE386F.8090706@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Rick Jones <rick.jones2@hp.com>,
	David Miller <davem@davemloft.net>, jgarzik@pobox.com,
	netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:47363 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751907AbYJUUiO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Oct 2008 16:38:14 -0400
In-Reply-To: <48FE386F.8090706@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 21 Oct 2008 22:15:43 +0200
Eric Dumazet <dada1@cosmosbay.com> wrote:

> Rick Jones a =C3=A9crit :
> > David Miller wrote:
> >> From: Stephen Hemminger <shemminger@vyatta.com>
> >> Date: Mon, 20 Oct 2008 19:09:22 -0700
> >>
> >>
> >>> Add support for recycling tx buffers into receive buffers.
> >>> This is experimental at this point.
> >>>
> >>> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> >>
> >>
> >> Experimental, but do you have any performance data at all?
> >> Just curious...
> >=20
> > I've not had a good emily litella moment all day so I'll ask - is t=
here=20
> > really that much in the way of suitable skb's which are completely =
free=20
> > after transmit completion?
>=20
> Or, if we take another way, say a VOIP RTP machine sends and receive =
20.000
>  packets per second, each being 200 bytes long, are transmited packet=
s
> correctly sized at sendto() time to be candidates for recycling ?

No. Most locally generate packets aren't going to be right size because
they will be too small, cloned or fragmented.  It really only helps whe=
n forwarding.
