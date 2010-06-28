From: James Courtier-Dutton <james.dutton@gmail.com>
Subject: Re: b44: Reset due to FIFO overflow.
Date: Mon, 28 Jun 2010 11:24:32 +0100
Message-ID: <AANLkTik6YBO7bVAy0NjdQGomYBsY-e8PqZ3-Je_vyx7B@mail.gmail.com>
References: <AANLkTinwnTw3Yqy3POghliZDRmRYUfJL6Gy67GNNLiYv@mail.gmail.com>
	<1277716394.4235.235.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:48642 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751921Ab0F1KYe convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jun 2010 06:24:34 -0400
Received: by fxm14 with SMTP id 14so502344fxm.19
        for <netdev@vger.kernel.org>; Mon, 28 Jun 2010 03:24:32 -0700 (PDT)
In-Reply-To: <1277716394.4235.235.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 28 June 2010 10:13, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
> Hi
>
> Problem is we dont know if a Receive Fifo overflow is a minor or majo=
r
> indication from b44 chip.
>
> A minor indication would be : Chip tells us one or more frame were lo=
st.
> No special action needed from driver.
>
> A major indication (as of current implemented in b44 driver) is :
> I am completely out of order and need a reset. Please do it.
>
> Patch to switch from major to minor indication is easy, but we dont k=
now
> if its valid or not.
>
> diff --git a/drivers/net/b44.h b/drivers/net/b44.h
> index e1905a4..514dc3a 100644
> --- a/drivers/net/b44.h
> +++ b/drivers/net/b44.h
> @@ -42,7 +42,7 @@
> =C2=A0#define =C2=A0ISTAT_EMAC =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A00x04000000 /* EMAC Interrupt */
> =C2=A0#define =C2=A0ISTAT_MII_WRITE =C2=A0 =C2=A0 =C2=A0 0x08000000 /=
* MII Write Interrupt */
> =C2=A0#define =C2=A0ISTAT_MII_READ =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A00x10000000 /* MII Read Interrupt */
> -#define =C2=A0ISTAT_ERRORS (ISTAT_DSCE|ISTAT_DATAE|ISTAT_DPE|ISTAT_R=
DU|ISTAT_RFO|ISTAT_TFU)
> +#define =C2=A0ISTAT_ERRORS (ISTAT_DSCE|ISTAT_DATAE|ISTAT_DPE|ISTAT_R=
DU|ISTAT_TFU)
> =C2=A0#define B44_IMASK =C2=A0 =C2=A0 =C2=A00x0024UL /* Interrupt Mas=
k */
> =C2=A0#define =C2=A0IMASK_DEF =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 (ISTAT_ERRORS | ISTAT_TO | ISTAT_RX | ISTAT_TX)
> =C2=A0#define B44_GPTIMER =C2=A0 =C2=A00x0028UL /* General Purpose Ti=
mer */
>
>
>

Ok, are you saying that all I have to do is apply this patch,
reproduce the problem condition, and if it recovers OK, then we can go
with this fix?
If so, I will try it out after work.

I will probably add a printk in before the ISTAT_ERRORS test, to
inform me when that ISTAT_RFO has actually happened.

But is doing nothing the right thing?
I would have thought that one would have to at least start and stop
the FIFO in order for the write/read pointers to be in the correct
positions or at least change the read pointer to do the equivalent of
flush the buffer.
Is there any of this sort of control over the FIFO possible?

Kind Regards

James
