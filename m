From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v5] net: ethernet: add driver for Aurora VLSI NB8800
 Ethernet controller
Date: Wed, 11 Nov 2015 06:09:21 -0800
Message-ID: <1447250961.17135.104.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1447172063-27234-1-git-send-email-mans@mansr.com>
	 <20151110233448.GA8646@electric-eye.fr.zoreil.com>
	 <yw1xio59pdw6.fsf@unicorn.mansr.com>
	 <20151110.211121.422193831316296487.davem@davemloft.net>
	 <yw1xa8qkpvy3.fsf@unicorn.mansr.com> <yw1x6118pu0o.fsf@unicorn.mansr.com>
	 <1447248595.17135.98.camel@edumazet-glaptop2.roam.corp.google.com>
	 <yw1x1tbwpry3.fsf@unicorn.mansr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, romieu@fr.zoreil.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	slash.tmp@free.fr
To: =?ISO-8859-1?Q?M=E5ns_Rullg=E5rd?= <mans@mansr.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:34727 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751283AbbKKOJY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Nov 2015 09:09:24 -0500
In-Reply-To: <yw1x1tbwpry3.fsf@unicorn.mansr.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-11-11 at 13:48 +0000, M=C3=A5ns Rullg=C3=A5rd wrote:
> Eric Dumazet <eric.dumazet@gmail.com> writes:
>=20
> > On Wed, 2015-11-11 at 13:04 +0000, M=C3=A5ns Rullg=C3=A5rd wrote:
> >
> >> I tried that, and throughput (as measured by iperf3) dropped by 2%=
=2E
> >> Maybe I did something wrong.
> >
> > What link speed have you used, what was the throughput you got,
> > and is the receiver using the same NIC ?
>=20
> 1Gbps link, 640 Mbps TCP transmit throughput to a PC with Intel NIC.
> Why does it matter what NIC the receiver has?

Because at 1Gb line rate, you better get GRO properly implemented in th=
e
receiver, so that TCP stack does not send one ACK every 2 MSS.

Send speed is also dependent on the number of ACK packets the sender ha=
s
to process.

This is why I suggested you use napi_gro_receive() in your driver.
