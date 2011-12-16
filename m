From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 00/10 net-next] Introduce per interface ipv4 statistics
Date: Fri, 16 Dec 2011 19:08:31 +0100
Message-ID: <1324058911.25554.82.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <igorm@etf.rs> <1324049163-11207-1-git-send-email-igorm@etf.rs>
	    <1324050080.25554.34.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	    <CAFdo_mWY3030_WsL_awXFMaviMA5MGJP_gMs0cM=6KeGQft6-Q@mail.gmail.com>
	   <1324053184.25554.47.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <alpine.DEB.2.00.1112161043080.26765@router.home>
	  <1324054244.25554.56.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	  <alpine.DEB.2.00.1112161053030.26765@router.home>
	 <1324055686.25554.66.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <alpine.DEB.2.00.1112161128060.26765@router.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: igorm@etf.rs, netdev@vger.kernel.org, davem@davemloft.net
To: Christoph Lameter <cl@linux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:35710 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753655Ab1LPSIf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Dec 2011 13:08:35 -0500
Received: by faar15 with SMTP id r15so3165389faa.19
        for <netdev@vger.kernel.org>; Fri, 16 Dec 2011 10:08:33 -0800 (PST)
In-Reply-To: <alpine.DEB.2.00.1112161128060.26765@router.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 16 d=C3=A9cembre 2011 =C3=A0 11:29 -0600, Christoph Lameter=
 a =C3=A9crit :

> I have some latency critical processes here and I wish I could get
> networking in general off the processor where the latency sensitive s=
tuff
> is running should that process decide to do some calls that cause net=
work
> I/O.
>=20
> Traditional networking is a slow process these days.


Most of the slow process is in the process scheduler actually and cache
line misses in large TCP structures, but also in many layers (Qdisc...)=
,
not counting icache footprint.

We slowly improve things, but its always a tradeoff (did I said code
bloat ?)

If you have dedicated network thread(s) in your application, bound to
the right cpu(s), then all network stack can be run on the cpus you
decide [ Also needs using correct irq affinities for the NIC interrupts=
]

This means your latency critical threads should delegate their network
IO (like disk IO) to other threads, _and_ avoid being blocked in
scheduler land.

Given the nature of socket api, I am not sure adding a layer to
transparently delegate network IO to a pool of dedicated cpus would be =
a
win.
