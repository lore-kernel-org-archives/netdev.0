From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Regression: Recent networking (qdisc?) patches break irda_get_next_speed()
Date: Tue, 21 Oct 2008 21:37:37 +0200
Message-ID: <48FE2F81.9060801@gmail.com>
References: <48FE1D52.6080903@ceibo.fiec.espol.edu.ec>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?ISO-8859-1?Q?Alex_Villac=ED=ADs_Lasso?=
	<avillaci@ceibo.fiec.espol.edu.ec>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.191]:40422 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751315AbYJUTgs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Oct 2008 15:36:48 -0400
Received: by nf-out-0910.google.com with SMTP id d3so1257039nfc.21
        for <netdev@vger.kernel.org>; Tue, 21 Oct 2008 12:36:46 -0700 (PDT)
In-Reply-To: <48FE1D52.6080903@ceibo.fiec.espol.edu.ec>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alex Villac=ED=ADs Lasso wrote, On 10/21/2008 08:20 PM:

> A regression has been introduced in 2.6.27 in the networking code, wh=
ich=20
> breaks the irda_get_next_speed() function used by some IrDA drivers,=20
> including ks959-sir, written by me. I have filed a bug at:
>=20
> http://bugzilla.kernel.org/show_bug.cgi?id=3D11795
>=20
> to keep track of this. I am still performing bisection to locate the=20
> exact commit that broke the code, but the bug involves an overwriting=
 of=20
> the beginning of a structure with extraneous data that makes the=20
> LAP_MAGIC check fail. I have tried searching the netdev archives, but=
=20
> there is no mention at all of regressions caused by this code. Milan=20
> Plzik at irda-users mentions the same problem affecting pxaficp_ir, a=
nd=20
> mentions recent qdisc patches as possible culprits.  Vasily Khoruzhic=
k=20
> reported this bug at irda-users, and a quick hack (not a proper fix)=20
> proposed by him involves padding "struct irda_skb_cb" with 4 bytes at=
=20
> the beginning of the structure to move everything else past the buggy=
=20
> scribbling.


Looks like the patch below could fit to your description.

Jarek P.

commit 175f9c1bba9b825d22b142d183c9e175488b260c
Author: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Date:   Sun Jul 20 00:08:47 2008 -0700

    net_sched: Add size table for qdiscs

    Add size table functions for qdiscs and calculate packet size in
    qdisc_enqueue().

    Based on patch by Patrick McHardy
     http://marc.info/?l=3Dlinux-netdev&m=3D115201979221729&w=3D2

    Signed-off-by: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
    Signed-off-by: David S. Miller <davem@davemloft.net>


