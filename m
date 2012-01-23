From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH/RESEND] drivers/net/ethernet: dev_alloc_skb to
 netdev_alloc_skb
Date: Mon, 23 Jan 2012 22:15:39 +0100
Message-ID: <1327353339.2587.7.camel@edumazet-laptop>
References: <1327343283-4830-1-git-send-email-netdev@pradeepdalvi.com>
	 <1327344034.6317.3.camel@joe2Laptop>
	 <CA+Dx6HY92Z8KtDXf73O3QMWLj__+Q2g7PxjiZ7omn+tuh8YK5A@mail.gmail.com>
	 <1327348561.7527.0.camel@joe2Laptop>
	 <CA+Dx6HbxEFLTMMGJ-ASY=4zNthRtWps6KnFiPNLAz6o+HVmS9g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Joe Perches <joe@perches.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Christoph Hellwig <hch@lst.de>, linux-kernel@vger.kernel.org
To: "Pradeep A. Dalvi" <netdev@pradeepdalvi.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+Dx6HbxEFLTMMGJ-ASY=4zNthRtWps6KnFiPNLAz6o+HVmS9g@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mardi 24 janvier 2012 =C3=A0 02:11 +0530, Pradeep A. Dalvi a =C3=A9c=
rit :

> Aah! Is that really needed? Cause from my understanding, priority GFP
> flag __GFP_DMA is anyway negated in __alloc_skb, in a way from all
> sources i.e. netdev_alloc_skb or dev_alloc_skb or even alloc_skb. Am =
I
> missing something here?

You should read the whole __alloc_skb() function and not only half of
it.

skb itself is allocated in the normal memory pool, (not GFP_DMA), since
it has no hardware requirement for a kernel structure.

But skb->head _is_ allocated with GFP_DMA if driver requested it.
