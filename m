From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: RPS runs with multiqueue NIC
Date: Tue, 22 Feb 2011 06:46:03 +0100
Message-ID: <1298353563.3360.6.camel@edumazet-laptop>
References: <4A6A2125329CFD4D8CC40C9E8ABCAB9F24D3DE6CC5@MILEXCH2.ds.jdsu.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jon Zhou <Jon.Zhou@jdsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f51.google.com ([209.85.214.51]:33489 "EHLO
	mail-bw0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751711Ab1BVFyS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Feb 2011 00:54:18 -0500
Received: by bwz10 with SMTP id 10so2871680bwz.10
        for <netdev@vger.kernel.org>; Mon, 21 Feb 2011 21:54:17 -0800 (PST)
In-Reply-To: <4A6A2125329CFD4D8CC40C9E8ABCAB9F24D3DE6CC5@MILEXCH2.ds.jdsu.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 21 f=C3=A9vrier 2011 =C3=A0 19:07 -0800, Jon Zhou a =C3=A9crit=
 :
> Hi
>=20
> What will happen if RPS runs on kernel 2.6.36.4 machine where a multi=
queue NIC intel x520 installed
> Will it decrease or improve performance?

It depends on the workload.

=46or typical TCP flows, hardware multiqueue is generally better,
especially if the NIC supports the ethtool -X command (so that you can
tune effective number of cpus dedicated to the softirq processing).
Packet are delivered directly to the CPU target, without taking an extr=
a
IPI.

=46or UDP workloads, adding RPS might be a win, because many NIC dont t=
ake
into account ports numbers in their hash computation, while
net/core/dev.c hash function does. If you receive trafic coming from a
single remote machine, RPS helps to spread flows between several cpus.



