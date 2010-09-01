From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: skb allocation size question
Date: Wed, 01 Sep 2010 21:04:45 +0200
Message-ID: <1283367885.2484.16.camel@edumazet-laptop>
References: <201009011151.02639.awilliams@atheros.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Aaron Williams <awilliams@atheros.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:38229 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754306Ab0IATEu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Sep 2010 15:04:50 -0400
Received: by ewy23 with SMTP id 23so4576911ewy.19
        for <netdev@vger.kernel.org>; Wed, 01 Sep 2010 12:04:49 -0700 (PDT)
In-Reply-To: <201009011151.02639.awilliams@atheros.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 01 septembre 2010 =C3=A0 11:51 -0700, Aaron Williams a =C3=A9=
crit :
> Hi,
>=20
> I have been trying to track down an issue in one of our drivers with =
SKB=20
> allocation and in my research I came across something that seems a bi=
t=20
> strange. In __alloc_skb, a block for the data allocates size + sizeof=
(struct=20
> skb_shared_info) bytes, yet skb->truesize is set to size + sizeof(str=
uct=20
> sk_buff). Is there a reason for this discrepancy?

Hi Aaron

Not really. We also could add in truesize the sizeof(struct
skb_shared_info).

Including sizeof(struct sk_buff) is enough to prevent a malicious user
filling kernel memory with skb of one byte of payload.

Problem is, adding this extra overhead could slowdown some applications=
,
using too small RCVBUF / SNDBUF settings.



