From: Richard Hartmann <richih.mailinglist@gmail.com>
Subject: Re: [Patch] fix packet loss and massive ping spikes with PPP
	multi-link
Date: Wed, 26 May 2010 10:47:36 +0200
Message-ID: <AANLkTikeld4fbr9r1Sq0jhfkWxf0ZlwOsufUIRvb1rFH@mail.gmail.com>
References: <2d460de71003260850x7f90d04cy79ac853464108182@mail.gmail.com>
	<AANLkTik_QdZN_nFoOVD3-1JTGN5oxRySCdV5_eDqvQve@mail.gmail.com>
	<4BFBA3F2.2000301@bfs.de>
	<AANLkTilnueP5HIfX03soMCYE93jubL000rpiOCN1xB2-@mail.gmail.com>
	<4BFC0942.2030103@bfs.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: erik_list@caneris.com
To: wharms@bfs.de, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-ppp@vger.kernel.org
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <4BFC0942.2030103@bfs.de>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=3D=3DIt seems LKML & netdev were dropped from the To list, re-adding=3D=
=3D

Hi Walter,


> =C2=A0if (ppp->rrsched % ppp->n_channels =3D=3D i)
>
> since both do not change in that while() loop you can calculate in ad=
vance
> perhaps ppp->rrsched %=3D ppp->n_channels before the while ?
> (that would reduce my bad feels about variables that only increments =
also :)

rrsched and i do change when appropriate. As they are used as a cheap
way to get round robin, rrsched is not even initialized. One can argue
that this should be done, but as it literally does not matter where the
value starts counting....


> btw: you are doing =C2=A0after loop() if(pch->chan =3D=3D NULL) conti=
nue;
> that means the else in the if below =C2=A0if (pch->chan) should never=
 be reached.
> Or is it likely that some channel will be dropped (?) ?

Channels could be dropped and we need to guard against that.


> btw: this is intentional ? looks strange
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if(ppp_ml_noexplode) {
> + =C2=A0 =C2=A0 =C2=A0 }
> + =C2=A0 =C2=A0 =C2=A0 else {

Leftover from various printks for debugging reasons.


Thanks for your feedback,
Richard
