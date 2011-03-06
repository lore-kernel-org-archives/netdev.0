From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [Patch] ariadne: fix possible null dereference
Date: Sun, 6 Mar 2011 21:00:13 +0100
Message-ID: <AANLkTiko+HzYMnGEtvb63Fzi2eNge6_iWPmk7EfjFma7@mail.gmail.com>
References: <20110306070832.GA26188@asset.uwaterloo.ca>
	<20110306111141.9cc51306.rdunlap@xenotime.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: j223yang@asset.uwaterloo.ca, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Randy Dunlap <rdunlap@xenotime.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:62860 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752607Ab1CFUAP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Mar 2011 15:00:15 -0500
In-Reply-To: <20110306111141.9cc51306.rdunlap@xenotime.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 6, 2011 at 20:11, Randy Dunlap <rdunlap@xenotime.net> wrote=
:
> On Sun, 6 Mar 2011 02:08:32 -0500 j223yang@asset.uwaterloo.ca wrote:
>
>> Hi Randy,
>> I have tested my patch, and it is ok now.
>> Could you please try patching again? Sorry for previous trouble.
>> Thank you!
>
> Acked-by: Randy Dunlap <rdunlap@xenotime.net>

Acked-by: Geert Uytterhoeven <geert@linux-m68k.org>

>> ------------------------------------------------------
>> This patch fixes bugzilla #13853:
>> https://bugzilla.kernel.org/show_bug.cgi?id=3D13853
>>
>> The patch removes dereference of 'dev' after testing for NULL.
>>
>> Signed-off-by: Jinqiu Yang<crindy646@gmail.com>
>> ---
>> =C2=A0ariadne.c | =C2=A0 =C2=A03 ++-
>> =C2=A01 file changed, 2 insertions(+), 1 deletion(-)
>>
>> diff --git a/drivers/net/ariadne.c b/drivers/net/ariadne.c
>> --- a/drivers/net/ariadne.c =C2=A0 2011-03-04 11:16:42.332164362 -05=
00
>> +++ b/drivers/net/ariadne.c =C2=A0 2011-03-05 21:11:52.949164759 -05=
00
>> @@ -420,7 +420,7 @@ static inline void ariadne_reset(struct
>> =C2=A0static irqreturn_t ariadne_interrupt(int irq, void *data)
>> =C2=A0{
>> =C2=A0 =C2=A0 =C2=A0struct net_device *dev =3D (struct net_device *)=
data;
>> - =C2=A0 =C2=A0volatile struct Am79C960 *lance =3D (struct Am79C960*=
)dev->base_addr;
>> + =C2=A0 =C2=A0volatile struct Am79C960 *lance;
>> =C2=A0 =C2=A0 =C2=A0struct ariadne_private *priv;
>> =C2=A0 =C2=A0 =C2=A0int csr0, boguscnt;
>> =C2=A0 =C2=A0 =C2=A0int handled =3D 0;
>> @@ -430,6 +430,7 @@ static irqreturn_t ariadne_interrupt(int
>> =C2=A0 =C2=A0 =C2=A0 return IRQ_NONE;
>> =C2=A0 =C2=A0 =C2=A0}
>>
>> + =C2=A0 =C2=A0lance =3D (struct Am79C960 *)dev->base_addr;
>> =C2=A0 =C2=A0 =C2=A0lance->RAP =3D CSR0; =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* PCnet-ISA Controll=
er Status */
>>
>> =C2=A0 =C2=A0 =C2=A0if (!(lance->RDP & INTR)) =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Check if any interrupt has been */

Gr{oetje,eeting}s,

=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-=
m68k.org

In personal conversations with technical people, I call myself a hacker=
=2E But
when I'm talking to journalists I just say "programmer" or something li=
ke that.
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0=C2=A0 =C2=A0=C2=A0 -- Linus Torvalds
