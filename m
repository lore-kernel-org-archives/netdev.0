From: Lucas Nussbaum <lucas.nussbaum@loria.fr>
Subject: Re: [PATCH 0/6] TCP CUBIC and Hystart
Date: Fri, 11 Mar 2011 17:08:09 +0100
Message-ID: <20110311160809.GA30082@xanadu.blop.info>
References: <20110310165119.224046957@vyatta.com>
 <20110311102809.GB15941@xanadu.blop.info>
 <AANLkTimi+nJ1-PO+JYjckg-Pw3+6-zJvqPvhMjf+1Lua@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>, davem@davemloft.net,
	rhee@ncsu.edu, netdev@vger.kernel.org
To: Sangtae Ha <sangtae.ha@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xanadu.blop.info ([178.79.145.134]:60686 "EHLO xanadu.blop.info"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754482Ab1CKQ2T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Mar 2011 11:28:19 -0500
Content-Disposition: inline
In-Reply-To: <AANLkTimi+nJ1-PO+JYjckg-Pw3+6-zJvqPvhMjf+1Lua@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/03/11 at 10:58 -0500, Sangtae Ha wrote:
> Hi Lucas,
>=20
> From your setup, ca->delay_min is 90 and this means the one-way delay
> is 90 >> 4 (5ms).
> And our gap detection threshold is 2ms, which means that if the gap i=
s
> loosely spread over 5ms with delayed ACKs, it can early terminate the
> slow start. But, given the optimal cwnd is 941 in your setup, exiting
> slow start one RTT before the loss (half of the optimal cwnd) is what
> hystart does.
>=20
> Since the resolution is now ms, can you change the gap detection to
> 1ms and run it again?
> Also, the following change you did doesn't hurt (1ms more train to
> detect the ACK train).

Hi,

Changing it to 1ms only improves the situation marginally.
[25271.861481] found ACK TRAIN: cwnd=3D835 now=3D2779244747 ca->last_ac=
k=3D2779244747 ca->round_start=3D2779244741 ca->delay_min=3D90 delay_mi=
n>>4=3D5 nbacks=3D261
[25291.507340] found ACK TRAIN: cwnd=3D585 now=3D2779264393 ca->last_ac=
k=3D2779264393 ca->round_start=3D2779264387 ca->delay_min=3D90 delay_mi=
n>>4=3D5 nbacks=3D221
[25327.585396] found ACK TRAIN: cwnd=3D1034 now=3D2779300471 ca->last_a=
ck=3D2779300471 ca->round_start=3D2779300465 ca->delay_min=3D90 delay_m=
in>>4=3D5 nbacks=3D245
[25347.300351] found ACK TRAIN: cwnd=3D1463 now=3D2779320186 ca->last_a=
ck=3D2779320186 ca->round_start=3D2779320180 ca->delay_min=3D90 delay_m=
in>>4=3D5 nbacks=3D427
[25390.702328] found ACK TRAIN: cwnd=3D587 now=3D2779363588 ca->last_ac=
k=3D2779363588 ca->round_start=3D2779363582 ca->delay_min=3D90 delay_mi=
n>>4=3D5 nbacks=3D211
[25394.775396] found ACK TRAIN: cwnd=3D588 now=3D2779367661 ca->last_ac=
k=3D2779367661 ca->round_start=3D2779367655 ca->delay_min=3D90 delay_mi=
n>>4=3D5 nbacks=3D242
[25402.061328] found ACK TRAIN: cwnd=3D1282 now=3D2779374947 ca->last_a=
ck=3D2779374947 ca->round_start=3D2779374941 ca->delay_min=3D90 delay_m=
in>>4=3D5 nbacks=3D335
[25404.894336] found ACK TRAIN: cwnd=3D585 now=3D2779377780 ca->last_ac=
k=3D2779377780 ca->round_start=3D2779377774 ca->delay_min=3D90 delay_mi=
n>>4=3D5 nbacks=3D205
[25408.584337] found ACK TRAIN: cwnd=3D587 now=3D2779381470 ca->last_ac=
k=3D2779381470 ca->round_start=3D2779381464 ca->delay_min=3D90 delay_mi=
n>>4=3D5 nbacks=3D209
[25421.699331] found ACK TRAIN: cwnd=3D856 now=3D2779394585 ca->last_ac=
k=3D2779394585 ca->round_start=3D2779394579 ca->delay_min=3D90 delay_mi=
n>>4=3D5 nbacks=3D239

There are still some cases when ack trains are detected too early.
--=20
| Lucas Nussbaum             MCF Universit=E9 Nancy 2 |
| lucas.nussbaum@loria.fr         LORIA / AlGorille |
| http://www.loria.fr/~lnussbau/  +33 3 54 95 86 19 |
