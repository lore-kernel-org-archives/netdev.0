From: James Courtier-Dutton <james.dutton@gmail.com>
Subject: Re: b44: Reset due to FIFO overflow.
Date: Mon, 28 Jun 2010 22:37:20 +0100
Message-ID: <AANLkTikVEwIj2Jjk8YMan4sHDNxpzhK3tlvpuAxYybSI@mail.gmail.com>
References: <AANLkTinwnTw3Yqy3POghliZDRmRYUfJL6Gy67GNNLiYv@mail.gmail.com>
	<1277716394.4235.235.camel@edumazet-laptop>
	<AANLkTik6YBO7bVAy0NjdQGomYBsY-e8PqZ3-Je_vyx7B@mail.gmail.com>
	<1277723471.4235.393.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:57078 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752184Ab0F1VhW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jun 2010 17:37:22 -0400
Received: by fxm14 with SMTP id 14so1006564fxm.19
        for <netdev@vger.kernel.org>; Mon, 28 Jun 2010 14:37:21 -0700 (PDT)
In-Reply-To: <1277723471.4235.393.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 28 June 2010 12:11, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> Le lundi 28 juin 2010 =C3=A0 11:24 +0100, James Courtier-Dutton a =C3=
=A9crit :
>> On 28 June 2010 10:13, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> >
>> > Hi
>> >
>> > Problem is we dont know if a Receive Fifo overflow is a minor or m=
ajor
>> > indication from b44 chip.
>> >
>> > A minor indication would be : Chip tells us one or more frame were=
 lost.
>> > No special action needed from driver.
>> >
>> > A major indication (as of current implemented in b44 driver) is :
>> > I am completely out of order and need a reset. Please do it.
>> >
>> > Patch to switch from major to minor indication is easy, but we don=
t know
>> > if its valid or not.
>> >
>> > diff --git a/drivers/net/b44.h b/drivers/net/b44.h
>> > index e1905a4..514dc3a 100644
>> > --- a/drivers/net/b44.h
>> > +++ b/drivers/net/b44.h
>> > @@ -42,7 +42,7 @@
>> > =C2=A0#define =C2=A0ISTAT_EMAC =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A00x04000000 /* EMAC Interrupt */
>> > =C2=A0#define =C2=A0ISTAT_MII_WRITE =C2=A0 =C2=A0 =C2=A0 0x0800000=
0 /* MII Write Interrupt */
>> > =C2=A0#define =C2=A0ISTAT_MII_READ =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A00x10000000 /* MII Read Interrupt */
>> > -#define =C2=A0ISTAT_ERRORS (ISTAT_DSCE|ISTAT_DATAE|ISTAT_DPE|ISTA=
T_RDU|ISTAT_RFO|ISTAT_TFU)
>> > +#define =C2=A0ISTAT_ERRORS (ISTAT_DSCE|ISTAT_DATAE|ISTAT_DPE|ISTA=
T_RDU|ISTAT_TFU)
>> > =C2=A0#define B44_IMASK =C2=A0 =C2=A0 =C2=A00x0024UL /* Interrupt =
Mask */
>> > =C2=A0#define =C2=A0IMASK_DEF =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 (ISTAT_ERRORS | ISTAT_TO | ISTAT_RX | ISTAT_TX)
>> > =C2=A0#define B44_GPTIMER =C2=A0 =C2=A00x0028UL /* General Purpose=
 Timer */
>> >
>> >
>> >
>>
>> Ok, are you saying that all I have to do is apply this patch,
>> reproduce the problem condition, and if it recovers OK, then we can =
go
>> with this fix?
>> If so, I will try it out after work.
>>
>
> Yes, please try the patch and tell us what happens.
>
> Note : It can be better, it can be worse.
>
> It can work on your b44 chip, and freeze another computer with anothe=
r
> b44 chip. Use at your own risk.
>

I tried the patch.
I also tried without the patch, but bypassed the hw reset in the RFO ca=
se.

In both cases, the hardware did not recover from the overflow.
An "ifconfig eth0 down" then "ifconfig eth0 up" was required to bring
it back to life, I.e. A manual hw reset.

What I did find is that once the RFO state is reached, it is not cleare=
d.
I think we need to find a way to clear the RFO state.
The RFO state is cleared after a HW reset.

Kind Regards

James
