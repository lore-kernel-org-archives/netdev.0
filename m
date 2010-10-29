From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 0/1] RFC: poll/select performance on datagram sockets
Date: Fri, 29 Oct 2010 21:27:11 +0200
Message-ID: <1288380431.2680.3.camel@edumazet-laptop>
References: <20101029191857.5f789d56@chocolatine.cbg.collabora.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Cyrill Gorcunov <gorcunov@openvz.org>,
	Alexey Dobriyan <adobriyan@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Pauli Nieminen <pauli.nieminen@collabora.co.uk>,
	Rainer Weikusat <rweikusat@mssgmbh.com>
To: Alban Crequy <alban.crequy@collabora.co.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:64620 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752138Ab0J2T1Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Oct 2010 15:27:16 -0400
In-Reply-To: <20101029191857.5f789d56@chocolatine.cbg.collabora.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 29 octobre 2010 =C3=A0 19:18 +0100, Alban Crequy a =C3=A9cr=
it :
> Hi,
>=20
> When a process calls the poll or select, the kernel calls (struct
> file_operations)->poll on every file descriptor and returns a mask of
> events which are ready. If the process is only interested by POLLIN
> events, the mask is still computed for POLLOUT and it can be expensiv=
e.
> For example, on Unix datagram sockets, a process running poll() with
> POLLIN will wakes-up when the remote end call read(). This is a
> performance regression introduced when fixing another bug by
> 3c73419c09a5ef73d56472dbfdade9e311496e9b and
> ec0d215f9420564fc8286dcf93d2d068bb53a07e.
>=20
> The attached program illustrates the problem. It compares the
> performance of sending/receiving data on an Unix datagram socket and
> select(). When the datagram sockets are not connected, the performanc=
e
> problem is not triggered, but when they are connected it becomes a lo=
t
> slower. On my computer, I have the following time:
>=20
> Connected datagram sockets: >4 seconds
> Non-connected datagram sockets: <1 second
>=20
> The patch attached in the next email fixes the performance problem: i=
t
> becomes <1 second for both cases. I am not suggesting the patch for
> inclusion; I would like to change the prototype of (struct
> file_operations)->poll instead of adding ->poll2. But there is a lot =
of
> poll functions to change (grep tells me 337 functions).
>=20
> Any opinions?

My opinion would be to use epoll() for this kind of workload.

Also, about unix_datagram_poll() being slow, it probably can be
addressed separately.



