From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v6 net-next 2/2] tcp: Add Redundant Data Bundling (RDB)
Date: Mon, 14 Mar 2016 14:15:40 -0700
Message-ID: <1457990140.31401.20.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1457028388-18226-1-git-send-email-bro.devel+kernel@gmail.com>
	 <1457028388-18226-3-git-send-email-bro.devel+kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Andreas Petlund <apetlund@simula.no>,
	Carsten Griwodz <griff@simula.no>,
	=?ISO-8859-1?Q?P=E5l?= Halvorsen <paalh@simula.no>,
	Jonas Markussen <jonassm@ifi.uio.no>,
	Kristian Evensen <kristian.evensen@gmail.com>,
	Kenneth Klette Jonassen <kennetkl@ifi.uio.no>
To: Bendik =?ISO-8859-1?Q?R=F8nning?= Opstad <bro.devel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:35369 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932387AbcCNVPn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2016 17:15:43 -0400
Received: by mail-pa0-f43.google.com with SMTP id td3so137860565pab.2
        for <netdev@vger.kernel.org>; Mon, 14 Mar 2016 14:15:43 -0700 (PDT)
In-Reply-To: <1457028388-18226-3-git-send-email-bro.devel+kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-03-03 at 19:06 +0100, Bendik R=C3=B8nning Opstad wrote:
> Redundant Data Bundling (RDB) is a mechanism for TCP aimed at reducin=
g
> the latency for applications sending time-dependent data.
>=20
> Latency-sensitive applications or services, such as online games,
> remote control systems, and VoIP, produce traffic with thin-stream
> characteristics, characterized by small packets and relatively high
> inter-transmission times (ITT). When experiencing packet loss, such
> latency-sensitive applications are heavily penalized by the need to
> retransmit lost packets, which increases the latency by a minimum of
> one RTT for the lost packet. Packets coming after a lost packet are
> held back due to head-of-line blocking, causing increased delays for
> all data segments until the lost packet has been retransmitted.

Acked-by: Eric Dumazet <edumazet@google.com>

Note that RDB probably should get some SNMP counters,
so that we get an idea of how many times a loss could be repaired.

Ideally, if the path happens to be lossless, all these pro active
bundles are overhead. Might be useful to make RDB conditional to
tp->total_retrans or something.
