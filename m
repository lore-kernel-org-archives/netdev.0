From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH/RESEND] drivers/net/ethernet: dev_alloc_skb to
 netdev_alloc_skb
Date: Mon, 23 Jan 2012 12:46:59 -0800
Message-ID: <1327351619.8074.3.camel@joe2Laptop>
References: <1327343283-4830-1-git-send-email-netdev@pradeepdalvi.com>
	 <1327344034.6317.3.camel@joe2Laptop>
	 <CA+Dx6HY92Z8KtDXf73O3QMWLj__+Q2g7PxjiZ7omn+tuh8YK5A@mail.gmail.com>
	 <1327348561.7527.0.camel@joe2Laptop>
	 <CA+Dx6HbxEFLTMMGJ-ASY=4zNthRtWps6KnFiPNLAz6o+HVmS9g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Christoph Hellwig <hch@lst.de>, linux-kernel@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "Pradeep A. Dalvi" <netdev@pradeepdalvi.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+Dx6HbxEFLTMMGJ-ASY=4zNthRtWps6KnFiPNLAz6o+HVmS9g@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2012-01-24 at 02:11 +0530, Pradeep A. Dalvi wrote:
> On Tue, Jan 24, 2012 at 1:26 AM, Joe Perches <joe@perches.com> wrote:
> > On Tue, 2012-01-24 at 00:49 +0530, Pradeep A. Dalvi wrote:
> >> On Tue, Jan 24, 2012 at 12:10 AM, Joe Perches <joe@perches.com> wrote:
> >> > On Mon, 2012-01-23 at 23:58 +0530, Pradeep A. Dalvi wrote:
> >> >> Replaced deprecating dev_alloc_skb with netdev_alloc_skb in drivers/net/ethernet
> >> >>   - Removed extra skb->dev = dev after netdev_alloc_skb
> >> > []
> >> >> diff --git a/drivers/net/ethernet/amd/lance.c b/drivers/net/ethernet/amd/lance.c
> >> > []
> >> >> @@ -871,13 +871,12 @@ lance_init_ring(struct net_device *dev, gfp_t gfp)
> >> >>               struct sk_buff *skb;
> >> >>               void *rx_buff;
> >> >>
> >> >> -             skb = alloc_skb(PKT_BUF_SZ, GFP_DMA | gfp);
> >> >> +             skb = netdev_alloc_skb(dev, PKT_BUF_SZ);
> >> >
> >> > This change seems suspect.
> >> Not really sure what made you suspect something in here. If you could
> >> help me understand possibly broken scenarios, would essentially be
> >> helpful. Thanks in advance!
> >
> > Where did the GFP_DMA go?
> 
> Aah! Is that really needed? Cause from my understanding, priority GFP
> flag __GFP_DMA is anyway negated in __alloc_skb, in a way from all
> sources i.e. netdev_alloc_skb or dev_alloc_skb or even alloc_skb. Am I
> missing something here?

It very well may be equivalent behavior.
I didn't look and didn't much care.

All I saw was an inequivalent transform with no change log
describing why the change was warranted.

cheers, Joe
