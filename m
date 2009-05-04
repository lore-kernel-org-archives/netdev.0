From: Omar Laazimani <omar.oberthur@gmail.com>
Subject: Re: [PATCH] : CDC EEM driver patch to be applied to 2.6.30 kernel
Date: Mon, 4 May 2009 17:51:37 +0200
Message-ID: <3a98b4410905040851i20d4192ax8f9ff3953e635979@mail.gmail.com>
References: <3a98b4410904270912g1838b534j2b53561b8caa1543@mail.gmail.com>
	 <20090428.044419.246576457.davem@davemloft.net>
	 <3a98b4410904280747x55be4a51y8043f827b93d0a80@mail.gmail.com>
	 <200905031713.58762.david-b@pacbell.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: David Brownell <david-b@pacbell.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f224.google.com ([209.85.219.224]:57715 "EHLO
	mail-ew0-f224.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753171AbZEDPvi convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2009 11:51:38 -0400
Received: by ewy24 with SMTP id 24so4049872ewy.37
        for <netdev@vger.kernel.org>; Mon, 04 May 2009 08:51:37 -0700 (PDT)
In-Reply-To: <200905031713.58762.david-b@pacbell.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks for your quick feedbacks.
I have tested your patch with our device and it's working well.

I have also added the TX side support for ZLP (see patch herein).
Please note that I can't test this issue as our device doesn't support =
it yet.

By the way, Just for curiosity, I have two questions about your patch
(see bellow) :

Thanks,
Omar

> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/*
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* EEM command packet=
:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* EEM (link) command=
 packet:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * b0..10: =A0 =A0 =A0=
bmEEMCmdParam
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * b11..13: =A0 =A0 bm=
EEMCmd
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* b14: =A0 =A0 =A0 =A0=
 bmReserved (0 by default)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* b15: =A0 =A0 =A0 =A0=
 1
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* b14: =A0 =A0 =A0 =A0=
 bmReserved (must be 0)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* b15: =A0 =A0 =A0 =A0=
 1 (EEM command)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (header & BIT(14)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 devdbg(=
dev, "reserved command %04x\n", header);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continu=
e;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb2 =3D skb_clone(skb,=
 GFP_ATOMIC);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (unlikely(!skb2))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto Co=
ntinue;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 bmEEMCmd =3D (header >>=
 11) & 0x7;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 switch (bmEEMCmd) {
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 bmEEMCmd =3D (BIT(11) &=
 header)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | (BIT(=
12) & header)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | (BIT(=
13) & header);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Responding to echo r=
equests is mandatory. */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 case 0: =A0 =A0 =A0 =A0=
 /* Echo command */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 len =3D=
 header & 0x7FF;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* bogu=
s command? */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (skb=
->len < len)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 return 0;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb2 =3D=
 skb_clone(skb, GFP_ATOMIC);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (unl=
ikely(!skb2))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 goto next;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb_tri=
m(skb2, len);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 put_una=
ligned_le16(BIT(15) | (1 << 11) | len,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 skb_push(skb2, 2));

why did you use 1 << 11 instead of BIT(11) ?

> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 eem_lin=
kcmd(dev, skb2);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>

> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* The bmCRC helps to=
 denote when the CRC field in
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* the Ethernet frame=
 contains a calculated CRC:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * =A0 =A0 =A0bmCRC =3D=
 1 =A0 =A0 =A0 : CRC is calculated
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * =A0 =A0 =A0bmCRC =3D=
 0 =A0 =A0 =A0 : CRC =3D 0xDEADBEEF
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 */
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (header & BIT(14)) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 u32 crc=
2;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 crc2 =3D=
 crc32_le(~0, skb2->data, len);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 crc2 =3D=
 ~crc2;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (unl=
ikely(crc !=3D crc2)) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 dev->stats.rx_errors++;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 goto Continue;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (unl=
ikely(crc !=3D 0xdeadbeef)) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 dev->stats.rx_errors++;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 goto Continue;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (header & BIT(14))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 crc2 =3D=
 ~crc32_le(~0, skb2->data, len);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 else
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 crc2 =3D=
 0xdeadbeef;
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 usbnet_skb_return(dev, =
skb2);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (is_last)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return =
crc =3D=3D crc2;

 Why do you prefer returning 0 and not incrementing
"dev->stats.rx_errors" instead of returning 1 (in all the cases) and
incrementing "dev->stats.rx_errors" in the error cases?

> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (unlikely(crc !=3D c=
rc2)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev->st=
ats.rx_errors++;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 usbnet_=
skb_return(dev, skb2);


=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D CUT HERE
fixed :
 - Zero length EEM packet support:
    * Handle on TX side


--- cdc_eem.c	2009-05-04 16:59:43.000000000 +0200
+++ cdc_eem_v5.c	2009-05-04 17:07:20.000000000 +0200
@@ -31,7 +31,6 @@
 #include <linux/usb/cdc.h>
 #include <linux/usb/usbnet.h>

-
 /*
  * This driver is an implementation of the CDC "Ethernet Emulation
  * Model" (EEM) specification, which encapsulates Ethernet frames
@@ -122,11 +121,14 @@
 	struct sk_buff	*skb2 =3D NULL;
 	u16		len =3D skb->len;
 	u32		crc =3D 0;
+	int		padlen =3D 0;

-	/* FIXME when ((len + EEM_HEAD + ETH_FCS_LEN) % dev->maxpacket)
+	/* When ((len + EEM_HEAD + ETH_FCS_LEN) % dev->maxpacket)
 	 * is zero, stick two bytes of zero length EEM packet on the end
 	 * (so the framework won't add invalid single byte padding).
 	 */
+	if (!((len + EEM_HEAD + ETH_FCS_LEN) % dev->maxpacket))
+		padlen +=3D 2;

 	if (!skb_cloned(skb)) {
 		int	headroom =3D skb_headroom(skb);
@@ -145,7 +147,7 @@
 		}
 	}

-	skb2 =3D skb_copy_expand(skb, EEM_HEAD, ETH_FCS_LEN, flags);
+	skb2 =3D skb_copy_expand(skb, EEM_HEAD, ETH_FCS_LEN + padlen, flags);
 	if (!skb2)
 		return NULL;

@@ -167,6 +169,10 @@
 	len =3D skb->len;
 	put_unaligned_le16(BIT(14) | len, skb_push(skb, 2));

+	/* Add zero length EEM packet if needed */
+	if (padlen)
+		*skb_put(skb, 2) =3D (u16) 0;
+
 	return skb;
 }
