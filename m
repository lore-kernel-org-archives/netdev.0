From: Andy Shevchenko <andy.shevchenko@gmail.com>
Subject: Re: [PATCH v5] net: ethernet: add driver for Aurora VLSI NB8800
 Ethernet controller
Date: Wed, 11 Nov 2015 00:40:53 +0200
Message-ID: <CAHp75VfsswYAvkkkHuaEvkTAgZhoGZQ1oQ_R9BwZgyZ3xRVDeg@mail.gmail.com>
References: <1447172063-27234-1-git-send-email-mans@mansr.com>
	<CAHp75Vch3vJEqYsCRUoctEmF0EoFx+0y7ZO+LjmdpQKAoikiOA@mail.gmail.com>
	<yw1xr3jxpjoy.fsf@unicorn.mansr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>, slash.tmp@free.fr
To: =?UTF-8?B?TcOlbnMgUnVsbGfDpXJk?= <mans@mansr.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <yw1xr3jxpjoy.fsf@unicorn.mansr.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 11, 2015 at 12:34 AM, M=C3=A5ns Rullg=C3=A5rd <mans@mansr.c=
om> wrote:
> Andy Shevchenko <andy.shevchenko@gmail.com> writes:
>
>>> +static inline void nb8800_maskb(struct nb8800_priv *priv, int reg,
>>> +                               u32 mask, u32 val)
>>> +{
>>> +       u32 old =3D nb8800_readb(priv, reg);
>>> +       u32 new =3D (old & ~mask) | val;
>>
>> Shoudn't be "=E2=80=A6 | (val & mask);" ?
>
> No, it's meant to replace the bits in mask with the corresponding bit=
s
> from val.

But you unconditionally use entire val value which might bring bits
outside of mask.

>> Block comments usually
>> /*
>>  * text
>>  */
>
> Documentation/CodingStyle says net/ and drivers/net/ are special, tho=
ugh
> currently a mix of styles can be found.  Personally, I don't
> particularly care.

OK.

>>> +       nb8800_writel(priv, NB8800_TX_DESC_ADDR, txb->dma_desc);
>>> +       wmb();          /* ensure desc addr is written before start=
ing DMA */
>>
>> Hm=E2=80=A6 Have I missed corresponding rmb() ? If it's about MMIO, =
perhaps mmiowb() ?
>
> Possibly.

Standalone wmb() doesn't make sense.

--=20
With Best Regards,
Andy Shevchenko
