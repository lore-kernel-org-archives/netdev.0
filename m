From: Yuchung Cheng <ycheng@google.com>
Subject: TCP ssthresh in Linux/RFC
Date: Thu, 22 Jul 2010 10:56:39 -0700
Message-ID: <AANLkTinZsZGHFodjh0O4WqQ1HhL9w2N9H=9yUDNjo_Fi@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:60137 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753313Ab0GVR5C convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jul 2010 13:57:02 -0400
Received: from hpaq3.eem.corp.google.com (hpaq3.eem.corp.google.com [172.25.149.3])
	by smtp-out.google.com with ESMTP id o6MHv1Sg024209
	for <netdev@vger.kernel.org>; Thu, 22 Jul 2010 10:57:01 -0700
Received: from vws2 (vws2.prod.google.com [10.241.21.130])
	by hpaq3.eem.corp.google.com with ESMTP id o6MHuxYR017342
	for <netdev@vger.kernel.org>; Thu, 22 Jul 2010 10:57:00 -0700
Received: by vws2 with SMTP id 2so480212vws.21
        for <netdev@vger.kernel.org>; Thu, 22 Jul 2010 10:56:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Linux set ssthresh upon entering recovery stage (tcp_fastretrans_al=
ert()) to
1) max(snd_cwnd/2, 2) in tcp_cong.c
2)=A0max((tp->snd_cwnd * beta) / BICTCP_BETA_SCALE, 2U) in tcp_cubic.c

but=A0RFC 5681 says =A0ssthresh =3D max (FlightSize / 2, 2*SMSS). It al=
so
specifically mentions
"=A0Implementation Note: An easy mistake to make is to simply use cwnd,
=A0=A0 rather than FlightSize, which in some implementations may
=A0=A0 incidentally increase well beyond rwnd."

I can think of a few pros and cons of both design, but would like to
hear Linux developers opinions first.

Yuchung
