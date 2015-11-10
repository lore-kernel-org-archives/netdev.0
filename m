From: =?iso-8859-1?Q?M=E5ns_Rullg=E5rd?= <mans@mansr.com>
Subject: Re: [PATCH v5] net: ethernet: add driver for Aurora VLSI NB8800 Ethernet controller
Date: Tue, 10 Nov 2015 23:07:24 +0000
Message-ID: <yw1xmvulpi6r.fsf@unicorn.mansr.com>
References: <1447172063-27234-1-git-send-email-mans@mansr.com>
	<CAHp75Vch3vJEqYsCRUoctEmF0EoFx+0y7ZO+LjmdpQKAoikiOA@mail.gmail.com>
	<yw1xr3jxpjoy.fsf@unicorn.mansr.com>
	<CAHp75VfsswYAvkkkHuaEvkTAgZhoGZQ1oQ_R9BwZgyZ3xRVDeg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "linux-kernel\@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>, slash.tmp@free.fr
To: Andy Shevchenko <andy.shevchenko@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAHp75VfsswYAvkkkHuaEvkTAgZhoGZQ1oQ_R9BwZgyZ3xRVDeg@mail.gmail.com>
	(Andy Shevchenko's message of "Wed, 11 Nov 2015 00:40:53 +0200")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andy Shevchenko <andy.shevchenko@gmail.com> writes:

> On Wed, Nov 11, 2015 at 12:34 AM, M=C3=A5ns Rullg=C3=A5rd <mans@mansr=
=2Ecom> wrote:
>> Andy Shevchenko <andy.shevchenko@gmail.com> writes:
>>
>>>> +static inline void nb8800_maskb(struct nb8800_priv *priv, int reg=
,
>>>> +                               u32 mask, u32 val)
>>>> +{
>>>> +       u32 old =3D nb8800_readb(priv, reg);
>>>> +       u32 new =3D (old & ~mask) | val;
>>>
>>> Shoudn't be "=E2=80=A6 | (val & mask);" ?
>>
>> No, it's meant to replace the bits in mask with the corresponding bi=
ts
>> from val.
>
> But you unconditionally use entire val value which might bring bits
> outside of mask.

Very well, I'll apply the mask to both then.

>>>> +       nb8800_writel(priv, NB8800_TX_DESC_ADDR, txb->dma_desc);
>>>> +       wmb();          /* ensure desc addr is written before star=
ting DMA */
>>>
>>> Hm=E2=80=A6 Have I missed corresponding rmb() ? If it's about MMIO,=
 perhaps mmiowb() ?
>>
>> Possibly.
>
> Standalone wmb() doesn't make sense.

It does if you need to enforce ordering between normal and I/O memory.
In fact, since the descriptor is filled in using normal memory accesses=
,
my understanding is that mmiowb() would be insufficient here.  The
comment could be improved, however.

--=20
M=C3=A5ns Rullg=C3=A5rd
mans@mansr.com
