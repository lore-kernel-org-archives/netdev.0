From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH net-next] net-gre-gro: Fix a bug that breaks the
 forwarding path
Date: Wed, 16 Jul 2014 15:12:02 +0300
Message-ID: <CAJZOPZJGyTdSB2LZcqrXcYdJAJsZfAmRDj4vUMBASfZQr6Pj_Q@mail.gmail.com>
References: <1405262780-20232-1-git-send-email-hkchu@google.com>
	<CAJZOPZ+wu=6t_AKoKg1KhVJ0=DhczfQ8ekDFKFLEkQv6d=cOfA@mail.gmail.com>
	<CAPshTCjiw8vFK9Y4APwsX5kWnKDByLuOn+1MJa4C08FOevZKQQ@mail.gmail.com>
	<CAJZOPZLwiT7LhxDFYdAq=0iU6heSwBQfCvwxXtoAXMqg=eNAmA@mail.gmail.com>
	<CAPshTCiKnKx_P=JLQcgjS36rWmCtSS43XYNJHeif9Z9yP8C36Q@mail.gmail.com>
	<CAJZOPZJcxb1j+_A2T=yN8bkjBH3CFjnb05q56dxAwtZ4i85Mpw@mail.gmail.com>
	<CAPshTCgCdJNH6rr-Yri0L8-aDL_kQfWbY9XtwVLxsoHcf-9Ghg@mail.gmail.com>
	<CA+mtBx8m+w9bkW8L+dDM-0coCVqgwx77x0kruQnGE+X2Y3+T3g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jerry Chu <hkchu@google.com>, Eric Dumazet <edumazet@google.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Wolfgang Walter <linux@stwm.de>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f169.google.com ([209.85.216.169]:56988 "EHLO
	mail-qc0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751409AbaGPMME (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jul 2014 08:12:04 -0400
Received: by mail-qc0-f169.google.com with SMTP id m20so659661qcx.28
        for <netdev@vger.kernel.org>; Wed, 16 Jul 2014 05:12:02 -0700 (PDT)
In-Reply-To: <CA+mtBx8m+w9bkW8L+dDM-0coCVqgwx77x0kruQnGE+X2Y3+T3g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 15, 2014 at 9:44 PM, Tom Herbert <therbert@google.com> wrote:
> Unfortunately, skb->encapsulation is overloaded with different
> meanings in TX and RX path. I think the invariant should be that if it
> is set, the inner headers are valid, so this is currently only useful
> on TX. For Rx, where it's used to indicate inner checksum was validated

I think what Jerry is trying to say here is that the TX part of the
forwarding path uses some pre-knowledge
from the RX part which sets some fields

> I intend to a add a separate field in skbuf (probably two
> bits to allow for multiple level encapsulations).
