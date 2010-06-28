From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: b44: Reset due to FIFO overflow.
Date: Mon, 28 Jun 2010 11:13:14 +0200
Message-ID: <1277716394.4235.235.camel@edumazet-laptop>
References: <AANLkTinwnTw3Yqy3POghliZDRmRYUfJL6Gy67GNNLiYv@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: James Courtier-Dutton <james.dutton@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:48038 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750834Ab0F1JNT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jun 2010 05:13:19 -0400
Received: by wyb38 with SMTP id 38so1583313wyb.19
        for <netdev@vger.kernel.org>; Mon, 28 Jun 2010 02:13:17 -0700 (PDT)
In-Reply-To: <AANLkTinwnTw3Yqy3POghliZDRmRYUfJL6Gy67GNNLiYv@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 28 juin 2010 =C3=A0 08:41 +0100, James Courtier-Dutton a =C3=A9=
crit :
> Hi,
>=20
> Reference:
> https://bugs.launchpad.net/ubuntu/+source/linux/+bug/279102
>=20
> I can see this bug and can reproduce it 100% on demand.
> The problem seems to be that when the b44 has a incoming FIFO buffer
> overflow, it resets the entire card, dis-associates with the access
> point and therefore takes some time before it can pass traffic again.
> Can anyone point me to some code that would just recover the FIFO
> instead of reset the entire card?
>=20
> I am a kernel developer, but I don't have any data sheets on this car=
d
> so was hoping someone with more knowledge of its workings, could help
> me.
>=20
> I can then test it, and see if it is a good fix or not.
>=20

Hi

Problem is we dont know if a Receive Fifo overflow is a minor or major
indication from b44 chip.

A minor indication would be : Chip tells us one or more frame were lost=
=2E
No special action needed from driver.

A major indication (as of current implemented in b44 driver) is :
I am completely out of order and need a reset. Please do it.

Patch to switch from major to minor indication is easy, but we dont kno=
w
if its valid or not.

diff --git a/drivers/net/b44.h b/drivers/net/b44.h
index e1905a4..514dc3a 100644
--- a/drivers/net/b44.h
+++ b/drivers/net/b44.h
@@ -42,7 +42,7 @@
 #define  ISTAT_EMAC		0x04000000 /* EMAC Interrupt */
 #define  ISTAT_MII_WRITE	0x08000000 /* MII Write Interrupt */
 #define  ISTAT_MII_READ		0x10000000 /* MII Read Interrupt */
-#define  ISTAT_ERRORS (ISTAT_DSCE|ISTAT_DATAE|ISTAT_DPE|ISTAT_RDU|ISTA=
T_RFO|ISTAT_TFU)
+#define  ISTAT_ERRORS (ISTAT_DSCE|ISTAT_DATAE|ISTAT_DPE|ISTAT_RDU|ISTA=
T_TFU)
 #define B44_IMASK	0x0024UL /* Interrupt Mask */
 #define  IMASK_DEF		(ISTAT_ERRORS | ISTAT_TO | ISTAT_RX | ISTAT_TX)
 #define B44_GPTIMER	0x0028UL /* General Purpose Timer */


