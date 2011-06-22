From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] gianfar v5: implement nfc
Date: Wed, 22 Jun 2011 09:48:00 -0700
Message-ID: <1308761280.10423.19.camel@Joe-Laptop>
References: <1308734972.7885.19.camel@DENEC1DT0191>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Sebastian =?ISO-8859-1?Q?P=F6hn?= <sebastian.poehn@belden.com>,
	Linux Netdev <netdev@vger.kernel.org>
To: Sebastian =?ISO-8859-1?Q?P=F6hn?=
	<sebastian.belden@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:3127 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755104Ab1FVQsB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jun 2011 12:48:01 -0400
In-Reply-To: <1308734972.7885.19.camel@DENEC1DT0191>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-06-22 at 11:29 +0200, Sebastian P=C3=B6hn wrote:
> First of all thanks for the feedback. I know the fgar_swap_*bits
> function is a bit ugly. The problem with your suggestion is that it i=
s
> necessary to swap a1<>a2 and b1<>b2 AT THE SAME TIME.

These swaps are done sequentially.
> Otherwise
> information the second swap is needing is swapped away by the first o=
ne.

How so?

> > swap_bits(temp_table->fe[new_first],
> >  temp_table->fe[old_first], 0xff80);
> > swap_bits(temp_table->fe[new_last],
> >  temp_table->fe[old_last], 0xff80);

new_first and old_first are swapped.
new_last and old_last are swapped.

> @@ -1356,10 +1356,13 @@ static void gfar_sort_mask_table(struct gfar_=
mask_entry *mask_table,
>  			new_first =3D mask_table[start].start + 1;
>  			new_last =3D mask_table[i - 1].end;

I'm a bit confused by this:

+		if (prev !=3D mask_table[i].block) {
+			old_first =3D mask_table[start].start + 1;
+			old_last =3D mask_table[i - 1].end;

[no changes to start or i]

+			new_first =3D mask_table[start].start + 1;
+			new_last =3D mask_table[i - 1].end;
+
+			gfar_swap_ff80_bits(&temp_table->fe[new_first],
+					&temp_table->fe[old_first],
+					&temp_table->fe[new_last],
+					&temp_table->fe[old_last]);

Doesn't this just swap the same bits around twice?


