From: "J. K. Cliburn" <jcliburn@gmail.com>
Subject: Re: [PATCH] atl1c: add missing parentheses
Date: Sun, 12 Jul 2009 19:08:01 -0500
Message-ID: <3400f2f60907121708x5edb854ch898af7e8e55d3497@mail.gmail.com>
References: <4A5A5852.4010901@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: atl1-devel@lists.sourceforge.net,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev <netdev@vger.kernel.org>, Jie Yang <jie.yang@atheros.com>
To: Roel Kluin <roel.kluin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f184.google.com ([209.85.210.184]:55142 "EHLO
	mail-yx0-f184.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751709AbZGMAIC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jul 2009 20:08:02 -0400
Received: by yxe14 with SMTP id 14so2599140yxe.33
        for <netdev@vger.kernel.org>; Sun, 12 Jul 2009 17:08:01 -0700 (PDT)
In-Reply-To: <4A5A5852.4010901@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adding Jie (Atheros maintainer) to cc list.

On Sun, Jul 12, 2009 at 4:40 PM, Roel Kluin<roel.kluin@gmail.com> wrote=
:
> Parentheses are required or the comparison occurs before the bitand.
>
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
> ---
> #include <stdio.h>
> int main()
> {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0printf("0 & 1 =3D=3D 0: %u\n", 0 & 1 =3D=3D=
 0);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0printf("1 & 1 =3D=3D 0: %u\n", 1 & 1 =3D=3D=
 0);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0printf("(0 & 1) =3D=3D 0: %u\n", (0 & 1) =3D=
=3D 0);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0printf("(1 & 1) =3D=3D 0: %u\n", (1 & 1) =3D=
=3D 0);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return 0;
> }
>
> output:
> 0 & 1 =3D=3D 0: 0
> 1 & 1 =3D=3D 0: 0
> (0 & 1) =3D=3D 0: 1
> (1 & 1) =3D=3D 0: 0
>
> diff --git a/drivers/net/atl1c/atl1c.h b/drivers/net/atl1c/atl1c.h
> index e1658ef..2a1120a 100644
> --- a/drivers/net/atl1c/atl1c.h
> +++ b/drivers/net/atl1c/atl1c.h
> @@ -188,14 +188,14 @@ struct atl1c_tpd_ext_desc {
> =C2=A0#define RRS_HDS_TYPE_DATA =C2=A0 =C2=A0 =C2=A02
>
> =C2=A0#define RRS_IS_NO_HDS_TYPE(flag) \
> - =C2=A0 =C2=A0 =C2=A0 (((flag) >> (RRS_HDS_TYPE_SHIFT)) & RRS_HDS_TY=
PE_MASK =3D=3D 0)
> + =C2=A0 =C2=A0 =C2=A0 ((((flag) >> (RRS_HDS_TYPE_SHIFT)) & RRS_HDS_T=
YPE_MASK) =3D=3D 0)
>
> =C2=A0#define RRS_IS_HDS_HEAD(flag) \
> - =C2=A0 =C2=A0 =C2=A0 (((flag) >> (RRS_HDS_TYPE_SHIFT)) & RRS_HDS_TY=
PE_MASK =3D=3D \
> + =C2=A0 =C2=A0 =C2=A0 ((((flag) >> (RRS_HDS_TYPE_SHIFT)) & RRS_HDS_T=
YPE_MASK) =3D=3D \
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0RRS_HDS_TYPE_HEAD)
>
> =C2=A0#define RRS_IS_HDS_DATA(flag) \
> - =C2=A0 =C2=A0 =C2=A0 (((flag) >> (RRS_HDS_TYPE_SHIFT)) & RRS_HDS_TY=
PE_MASK =3D=3D \
> + =C2=A0 =C2=A0 =C2=A0 ((((flag) >> (RRS_HDS_TYPE_SHIFT)) & RRS_HDS_T=
YPE_MASK) =3D=3D \
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0RRS_HDS_TYPE_DATA)
>
> =C2=A0/* rrs word 3 bit 0:31 */
> @@ -245,7 +245,7 @@ struct atl1c_tpd_ext_desc {
> =C2=A0#define RRS_PACKET_TYPE_802_3 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
1
> =C2=A0#define RRS_PACKET_TYPE_ETH =C2=A0 =C2=A00
> =C2=A0#define RRS_PACKET_IS_ETH(word) \
> - =C2=A0 =C2=A0 =C2=A0 (((word) >> RRS_PACKET_TYPE_SHIFT) & RRS_PACKE=
T_TYPE_MASK =3D=3D \
> + =C2=A0 =C2=A0 =C2=A0 ((((word) >> RRS_PACKET_TYPE_SHIFT) & RRS_PACK=
ET_TYPE_MASK) =3D=3D \
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0RRS_PACKET_TYPE_ETH)
> =C2=A0#define RRS_RXD_IS_VALID(word) \
> =C2=A0 =C2=A0 =C2=A0 =C2=A0((((word) >> RRS_RXD_UPDATED_SHIFT) & RRS_=
RXD_UPDATED_MASK) =3D=3D 1)
>
