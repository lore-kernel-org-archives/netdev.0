From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: [PATCH 2/2] packet: Add fanout support.
Date: Tue, 05 Jul 2011 20:20:32 +0200
Message-ID: <1309890032.2545.8.camel@edumazet-laptop>
References: <20110704.212014.236340473910292460.davem@davemloft.net>
	 <1309846875.2720.43.camel@edumazet-laptop>  <4E12B5A6.2020802@inliniac.net>
	 <1309849214.2720.45.camel@edumazet-laptop>
	 <D3F292ADF945FB49B35E96C94C2061B91257D61B@nsmail.netscout.com>
	 <1309882577.2271.23.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <D3F292ADF945FB49B35E96C94C2061B91257D6E1@nsmail.netscout.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Victor Julien <victor@inliniac.net>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: "Loke, Chetan" <Chetan.Loke@netscout.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:46436 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751320Ab1GESUf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2011 14:20:35 -0400
Received: by wyg8 with SMTP id 8so4181155wyg.19
        for <netdev@vger.kernel.org>; Tue, 05 Jul 2011 11:20:34 -0700 (PDT)
In-Reply-To: <D3F292ADF945FB49B35E96C94C2061B91257D6E1@nsmail.netscout.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 05 juillet 2011 =C3=A0 13:35 -0400, Loke, Chetan a =C3=A9crit =
:

> Sure, a lookup is needed(to steer what I call - Hot/Cold flows) and
> was proposed by me on the oisf mailing list. Always, use the ip_id bi=
t
> then? Another problem that needs to be solved is, what if some
> decoders are overloaded, then what? How will this scheme work? How
> will we utilize other CPUs? RPS is needed for sure.
>=20
> If we maintain a i) per port lookup-table ii) 2^20 flows/table and
> iii) 16 bytes/flow(one can also squeeze it down to 8 bytes) then we
> will need around 32MB worth memory/port. It's not a huge memory
> pressure for folks who want to use linux for doing IPS/IDS sort of
> stuff.
>=20
> User-space decoders end up copying the packet anyways. So fanout can
> be implemented in user-space to achieve effective CPU utilization.
> As long as we don't bounce on different CPU-socket we could be ok.

This is the problem we want to address.

Going into user-space to perform the fanout is what you already have
today, with one socket, one thread doing the fanout to worker threads.

David patch is non adaptative : its a hash on N queue, with a fixed has=
h
function.

What you want is to add another 'control queue' where new flows are
directed. Then user application is able to reinject into kernel flow
director the "This flow should go to queue X" information.

Or, let the kernel do a mix of rxhash and loadbalance : Be able to
select a queue for a new flow without user land control, using a Flow
hash table.





