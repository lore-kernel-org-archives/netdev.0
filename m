From: Salam Noureddine <noureddine@arista.com>
Subject: Re: [OOPS] In __netif_receive_skb_core
Date: Mon, 11 Jan 2016 17:19:05 -0800
Message-ID: <CAO7SqHC+fTCyNd8ukSH4tJ1qPvAYzMGSfhrzXmMn0NLve6NTQA@mail.gmail.com>
References: <568EA671.7000502@gmail.com>
	<56929985.3020502@gmail.com>
	<1452457610.16445.13.camel@edumazet-glaptop2.roam.corp.google.com>
	<5694188F.80907@gmail.com>
	<CAO7SqHA9dNUDG+pYJoQvipE_ErM4Bgo0_o9er_OLxZLDgNVJ8Q@mail.gmail.com>
	<56944DFA.4050002@gmail.com>
	<1452560786.1223.6.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Ivaylo Dimitrov <ivo.g.dimitrov.75@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	=?UTF-8?Q?Pali_Roh=C3=A1r?= <pali.rohar@gmail.com>,
	Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Sebastian Reichel <sre@kernel.org>,
	"linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1452560786.1223.6.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It must be that skb->dev was changed to NULL inside of
__netif_receive_skb_core, otherwise we would have crashed much
earlier. Also, orig_dev is saved at the beginning. Possibly a device
is layered on top of the original device.

On Mon, Jan 11, 2016 at 5:06 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Tue, 2016-01-12 at 02:51 +0200, Ivaylo Dimitrov wrote:
>
>>
>> I put some additional printks around that code, and it turned out that
>> skb->dev is null, so "if (unlikely(skb->dev != orig_dev))" succeeds, but
>> "&skb->dev->ptype_specific" oopses.
>
> Nice find !
>
> Now lets find what possibly called netif_rx() with skb->dev == NULL
>
> (This is illegal)
>
>
>
