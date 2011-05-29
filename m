From: Eric Miao <eric.y.miao@gmail.com>
Subject: Re: [PATCH] pxa: don't ask for a buffer from DMA zone
Date: Sun, 29 May 2011 18:28:09 +0800
Message-ID: <BANLkTim6eXD3NQs3LNKUwz345x-D1RdBDg@mail.gmail.com>
References: <1306658575-17160-1-git-send-email-dbaryshkov@gmail.com> <20110529102456.GX24876@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>,
	Samuel Ortiz <samuel@sortiz.org>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:45603 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752046Ab1E2K23 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 May 2011 06:28:29 -0400
Received: by vws1 with SMTP id 1so2148549vws.19
        for <netdev@vger.kernel.org>; Sun, 29 May 2011 03:28:29 -0700 (PDT)
In-Reply-To: <20110529102456.GX24876@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 29, 2011 at 6:24 PM, Russell King - ARM Linux
<linux@arm.linux.org.uk> wrote:
> On Sun, May 29, 2011 at 12:42:55PM +0400, Dmitry Eremin-Solenikov wro=
te:
>> PXA don't have special DMA zone. And since
>> 197b59ae6e8bee56fcef37ea2482dc08414e2ac (mm: fail GFP_DMA allocation=
s
>> when ZONE_DMA is not configured) allocation with GFP_DMA set will fa=
il
>> with a trace like this:
>
> These buffers are never used with DMA, its only used with the PIO act=
ivity
> when in SIR mode. =C2=A0When in FIR mode, and DMA is being used, we c=
opy it to
> a block of memory allocated by dma_coherent_alloc(). =C2=A0So the GFP=
_DMA
> annotation here is redundant.
>
> And that's probably more important to document in the changelog... it=
s not
> that PXA doesn't have a special DMA zone, it's that the driver doesn'=
t do
> DMA on these buffers so its pointless marking them with GFP_DMA.
>

Not really sure about the whole story, but further speaking, for
architectures like
PXA and most other ARM SoCs, where DMA can happen anywhere, does this
mean we don't even need to put GFP_DMA flag when doing memory allocatio=
n?


>> =C2=A0static int pxa_irda_init_iobuf(iobuff_t *io, int size)
>> =C2=A0{
>> - =C2=A0 =C2=A0 io->head =3D kmalloc(size, GFP_KERNEL | GFP_DMA);
>> + =C2=A0 =C2=A0 io->head =3D kmalloc(size, GFP_KERNEL);
>> =C2=A0 =C2=A0 =C2=A0 if (io->head !=3D NULL) {
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 io->truesize =3D si=
ze;
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 io->in_frame =3D FA=
LSE;
>> --
>> 1.7.4.4
>>
>>
>> _______________________________________________
>> linux-arm-kernel mailing list
>> linux-arm-kernel@lists.infradead.org
>> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel
>
