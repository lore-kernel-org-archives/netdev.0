From: Damian Lukowski <damian@tvk.rwth-aachen.de>
Subject: Re: [PATCH] tcp: Fix for stalling connections
Date: Mon, 07 Dec 2009 01:32:51 +0100
Message-ID: <4B1C4D33.9050201@tvk.rwth-aachen.de>
References: <4B1C4C25.1070104@tvk.rwth-aachen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta-1.ms.rz.RWTH-Aachen.DE ([134.130.7.72]:58725 "EHLO
	mta-1.ms.rz.rwth-aachen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934563AbZLGAcp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Dec 2009 19:32:45 -0500
Received: from ironport-out-1.rz.rwth-aachen.de ([134.130.5.40])
 by mta-1.ms.rz.RWTH-Aachen.de
 (Sun Java(tm) System Messaging Server 6.3-7.04 (built Sep 26 2008))
 with ESMTP id <0KU900GDCAURWYD0@mta-1.ms.rz.RWTH-Aachen.de> for
 netdev@vger.kernel.org; Mon, 07 Dec 2009 01:32:51 +0100 (CET)
Received: from [137.226.143.131] (nexus.tvk.RWTH-Aachen.DE [137.226.143.131])
	by relay.rwth-aachen.de (8.13.8+Sun/8.13.8/1) with ESMTP id nB70Wp3x005428	for
 <netdev@vger.kernel.org>; Mon, 07 Dec 2009 01:32:51 +0100 (CET)
In-reply-to: <4B1C4C25.1070104@tvk.rwth-aachen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Damian Lukowski schrieb:
> This patch fixes a problem in the TCP connection timeout calculation.
> Currently, timeout decisions are made on the basis of the current
> tcp_time_stamp and retrans_stamp, which is usually set at the first
> retransmission.
> However, if the retransmission fails in tcp_retransmit_skb(),
> retrans_stamp is not updated and remains zero. This leads to wrong
> decisions in retransmits_timed_out() if tcp_time_stamp is larger than
> the specified timeout, which is very likely.
> In this case, the TCP connection dies after the first attempted
> (and unsuccessful) retransmission.
>=20
> With this patch, tcp_skb_cb->when is used instead, when retrans_stamp
> is not available.
>=20
> Thanks to Ilpo J=E4rvinen for code suggestions.

=2E.. and Frederic Leroy for testing. ;)
