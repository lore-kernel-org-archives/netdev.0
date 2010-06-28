From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: b44: Reset due to FIFO overflow.
Date: Mon, 28 Jun 2010 13:11:11 +0200
Message-ID: <1277723471.4235.393.camel@edumazet-laptop>
References: <AANLkTinwnTw3Yqy3POghliZDRmRYUfJL6Gy67GNNLiYv@mail.gmail.com>
	 <1277716394.4235.235.camel@edumazet-laptop>
	 <AANLkTik6YBO7bVAy0NjdQGomYBsY-e8PqZ3-Je_vyx7B@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: James Courtier-Dutton <james.dutton@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:57416 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751504Ab0F1LLQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jun 2010 07:11:16 -0400
Received: by wyb38 with SMTP id 38so1665470wyb.19
        for <netdev@vger.kernel.org>; Mon, 28 Jun 2010 04:11:15 -0700 (PDT)
In-Reply-To: <AANLkTik6YBO7bVAy0NjdQGomYBsY-e8PqZ3-Je_vyx7B@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 28 juin 2010 =C3=A0 11:24 +0100, James Courtier-Dutton a =C3=A9=
crit :
> On 28 June 2010 10:13, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> >
> > Hi
> >
> > Problem is we dont know if a Receive Fifo overflow is a minor or ma=
jor
> > indication from b44 chip.
> >
> > A minor indication would be : Chip tells us one or more frame were =
lost.
> > No special action needed from driver.
> >
> > A major indication (as of current implemented in b44 driver) is :
> > I am completely out of order and need a reset. Please do it.
> >
> > Patch to switch from major to minor indication is easy, but we dont=
 know
> > if its valid or not.
> >
> > diff --git a/drivers/net/b44.h b/drivers/net/b44.h
> > index e1905a4..514dc3a 100644
> > --- a/drivers/net/b44.h
> > +++ b/drivers/net/b44.h
> > @@ -42,7 +42,7 @@
> >  #define  ISTAT_EMAC            0x04000000 /* EMAC Interrupt */
> >  #define  ISTAT_MII_WRITE       0x08000000 /* MII Write Interrupt *=
/
> >  #define  ISTAT_MII_READ                0x10000000 /* MII Read Inte=
rrupt */
> > -#define  ISTAT_ERRORS (ISTAT_DSCE|ISTAT_DATAE|ISTAT_DPE|ISTAT_RDU|=
ISTAT_RFO|ISTAT_TFU)
> > +#define  ISTAT_ERRORS (ISTAT_DSCE|ISTAT_DATAE|ISTAT_DPE|ISTAT_RDU|=
ISTAT_TFU)
> >  #define B44_IMASK      0x0024UL /* Interrupt Mask */
> >  #define  IMASK_DEF             (ISTAT_ERRORS | ISTAT_TO | ISTAT_RX=
 | ISTAT_TX)
> >  #define B44_GPTIMER    0x0028UL /* General Purpose Timer */
> >
> >
> >
>=20
> Ok, are you saying that all I have to do is apply this patch,
> reproduce the problem condition, and if it recovers OK, then we can g=
o
> with this fix?
> If so, I will try it out after work.
>=20

Yes, please try the patch and tell us what happens.

Note : It can be better, it can be worse.

It can work on your b44 chip, and freeze another computer with another
b44 chip. Use at your own risk.


> I will probably add a printk in before the ISTAT_ERRORS test, to
> inform me when that ISTAT_RFO has actually happened.
>=20

In this case, you also need to add ISTAT_RFO to IMASK_DEF. My patch
completely ignores ISTAT_RFO and NIC wont generate an interrupt for thi=
s
event.

> But is doing nothing the right thing?

If chip only signals an overflow and can revover, its pretty like losin=
g
a frame on a busy network. It happens and you dont have a report for
this.

> I would have thought that one would have to at least start and stop
> the FIFO in order for the write/read pointers to be in the correct
> positions or at least change the read pointer to do the equivalent of
> flush the buffer.

All this depends on hardware bits I dont have access to.

> Is there any of this sort of control over the FIFO possible?
>=20


Probably, but I guess if broadcam guys did not implement it, they
probably have a good reason :)



