From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v6] net: add Faraday FTMAC100 10/100 Ethernet driver
Date: Tue, 01 Mar 2011 06:59:48 +0100
Message-ID: <1298959188.2676.32.camel@edumazet-laptop>
References: <1298539762-2242-1-git-send-email-ratbert.chuang@gmail.com>
	 <1298627845-1583-1-git-send-email-ratbert.chuang@gmail.com>
	 <1298634040.2659.32.camel@edumazet-laptop>
	 <AANLkTimeDR27Q7fcBmB0ix7Q_pRT_GDpc7S3LO21-fh-@mail.gmail.com>
	 <1298958336.2676.21.camel@edumazet-laptop>
	 <AANLkTi=Sp-mAV1556pZvCvHzQ=MQNHUzjo0ap2DhKwWe@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	bhutchings@solarflare.com, joe@perches.com, dilinger@queued.net,
	mirqus@gmail.com, davem@davemloft.net,
	Po-Yu Chuang <ratbert@faraday-tech.com>
To: Po-Yu Chuang <ratbert.chuang@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTi=Sp-mAV1556pZvCvHzQ=MQNHUzjo0ap2DhKwWe@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mardi 01 mars 2011 =C3=A0 13:51 +0800, Po-Yu Chuang a =C3=A9crit :
> On Tue, Mar 1, 2011 at 1:45 PM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:

> > I am only wondering then if not using fragments would be faster the=
n
> > (eventually doing copybreaks for small frames like tg3)
>=20
> Although not many circumstances are tested.
> iperf shows that it is a little faster to use fragments than memcpy, =
so...

This might be a side effect of skb->truesize being smaller with
fragments than "regular packets" and socket backlog congestion.

If a full page was really accounted for in skb->truesize, instead of
used length, performance might be the same or lower :(

-	skb->truesize +=3D length;
+	skb->truesize +=3D PAGE_SIZE;

This has nothing to do with your driver, but a core implementation
detail.
