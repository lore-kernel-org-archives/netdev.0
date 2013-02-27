From: "Roberts, Lee A." <lee.roberts@hp.com>
Subject: RE: [PATCH 0/4] sctp: fix association hangs due to
 reassembly/ordering logic
Date: Wed, 27 Feb 2013 18:55:36 +0000
Message-ID: <D64EC45690EF85409BA6C4730E0162244310EF1F@G4W3231.americas.hpqcorp.net>
References: <1361889376-22171-1-git-send-email-lee.roberts@hp.com>
 <20130227.130959.379760800169434112.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-7
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0015.houston.hp.com ([15.201.24.18]:18963 "EHLO
	g4t0015.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760334Ab3B0S5H convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Feb 2013 13:57:07 -0500
In-Reply-To: <20130227.130959.379760800169434112.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I missed the change in the calling sequence for sctp_ulpq_partial_deliv=
ery()
when porting the changes forward from 3.2.x.  An updated patch has been=
 sent.

                                             - Lee Roberts

-----Original Message-----
=46rom: David Miller [mailto:davem@davemloft.net]=20
Sent: Wednesday, February 27, 2013 11:10 AM
To: Roberts, Lee A.
Cc: netdev@vger.kernel.org
Subject: Re: [PATCH 0/4] sctp: fix association hangs due to reassembly/=
ordering logic
Importance: High

=46rom: "Lee A. Roberts" <lee.roberts@hp.com>
Date: Tue, 26 Feb 2013 07:36:12 -0700

> From: "Lee A. Roberts" <lee.roberts@hp.com>
>=20
> This series of patches resolves several SCTP association hangs observ=
ed during
> SCTP stress testing.  Observable symptoms include communications hang=
s with
> data being held in the association reassembly and/or lobby (ordering)=
 queues.
> Close examination of reassembly/ordering queues may show either dupli=
cated
> or missing packets.
>=20
> Lee A. Roberts (4):
>   sctp: fix association hangs due to off-by-one errors in
>     sctp_tsnmap_grow()
>   sctp: fix association hangs due to reneging packets below the
>     cumulative TSN ACK point
>   sctp: fix association hangs due to errors when reneging events from
>     the ordering queue
>   sctp: fix association hangs due to partial delivery errors

Appying these patches breaks the build:

net/sctp/ulpqueue.c: In function =A1sctp_ulpq_renege=A2:
net/sctp/ulpqueue.c:1115:4: warning: passing argument 2 of =A1sctp_ulpq=
_partial_delivery=A2 makes integer from pointer without a cast [enabled=
 by default]
net/sctp/ulpqueue.c:1038:6: note: expected =A1gfp_t=A2 but argument is =
of type =A1struct sctp_chunk *=A2
net/sctp/ulpqueue.c:1115:4: error: too many arguments to function =A1sc=
tp_ulpq_partial_delivery=A2
net/sctp/ulpqueue.c:1038:6: note: declared here
