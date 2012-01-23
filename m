From: "Pradeep A. Dalvi" <netdev@pradeepdalvi.com>
Subject: Re: [PATCH/RESEND] drivers/net/ethernet: dev_alloc_skb to netdev_alloc_skb
Date: Tue, 24 Jan 2012 04:34:08 +0530
Message-ID: <CA+Dx6HZJpZnvJG91G4ybC_-dNWRhVkPcqa+ANCcBOHU0nY9Djg@mail.gmail.com>
References: <CA+Dx6HY92Z8KtDXf73O3QMWLj__+Q2g7PxjiZ7omn+tuh8YK5A@mail.gmail.com>
	<1327348561.7527.0.camel@joe2Laptop>
	<CA+Dx6HbxEFLTMMGJ-ASY=4zNthRtWps6KnFiPNLAz6o+HVmS9g@mail.gmail.com>
	<20120123.165329.738852681807240808.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: joe@perches.com, netdev@vger.kernel.org, hch@lst.de,
	linux-kernel@vger.kernel.org, eric.dumazet@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120123.165329.738852681807240808.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 24, 2012 at 3:23 AM, David Miller <davem@davemloft.net> wro=
te:
> From: "Pradeep A. Dalvi" <netdev@pradeepdalvi.com>
> Date: Tue, 24 Jan 2012 02:11:43 +0530
>
>> On Tue, Jan 24, 2012 at 1:26 AM, Joe Perches <joe@perches.com> wrote=
:
>>> On Tue, 2012-01-24 at 00:49 +0530, Pradeep A. Dalvi wrote:
>>>> On Tue, Jan 24, 2012 at 12:10 AM, Joe Perches <joe@perches.com> wr=
ote:
>>>> > On Mon, 2012-01-23 at 23:58 +0530, Pradeep A. Dalvi wrote:
>>>> >> Replaced deprecating dev_alloc_skb with netdev_alloc_skb in dri=
vers/net/ethernet
>>>> >> =A0 - Removed extra skb->dev =3D dev after netdev_alloc_skb
>>>> > []
>>>> >> diff --git a/drivers/net/ethernet/amd/lance.c b/drivers/net/eth=
ernet/amd/lance.c
>>>> > []
>>>> >> @@ -871,13 +871,12 @@ lance_init_ring(struct net_device *dev, g=
fp_t gfp)
>>>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct sk_buff *skb;
>>>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 void *rx_buff;
>>>> >>
>>>> >> - =A0 =A0 =A0 =A0 =A0 =A0 skb =3D alloc_skb(PKT_BUF_SZ, GFP_DMA=
 | gfp);
>>>> >> + =A0 =A0 =A0 =A0 =A0 =A0 skb =3D netdev_alloc_skb(dev, PKT_BUF=
_SZ);
>>>> >
>>>> > This change seems suspect.
>>>> Not really sure what made you suspect something in here. If you co=
uld
>>>> help me understand possibly broken scenarios, would essentially be
>>>> helpful. Thanks in advance!
>>>
>>> Where did the GFP_DMA go?
>>
>> Aah! Is that really needed? Cause from my understanding, priority GF=
P
>> flag __GFP_DMA is anyway negated in __alloc_skb, in a way from all
>> sources i.e. netdev_alloc_skb or dev_alloc_skb or even alloc_skb. Am=
 I
>> missing something here?
>
> GFP_DATA is negated for the SKB metadata allocation, but preserved fo=
r
> the actual packet data allocation.

Pardon my ignorance! Although this error occurred _exactly like_ the
typo in above statement. At the same time, I also called for help for
this special case.

> Could you please back off a bit and take your time on these changes?
>
> Your transformations are adding bugs, and you make it clear that you
> don't even understand how the allocation functions work semantically.
>
> I don't really think you are knowledgable enough to make these
> transformations safely at this time, and this is needlessly wasting
> patch reviewer resources.

There are first 4 patches with trivial changes. And 5th patch
(including first 4) has been resubmitted reverting errors in this
file. I know I made a mistake, which I've accepted and corrected as
well. Although above statements are kind of discouraging &
unnecessary, especially when changes in 1 file are incorrect out of
118 files.

If I expected your assistance, it was for certain special cases. And
so far has received correct directions, and above typo/spell-mistake
doesn't really redefine you or reconstruct somebody else in our eyes.
I still would expect your help wherever possible. And needlessly, you
remain the same.

Cheers,
Pradeep A. Dalvi
