From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC PATCH] common receive API + r8169 use
Date: Tue, 2 Aug 2011 14:15:00 -0700
Message-ID: <20110802141500.3c99185b@nehalam.ftrdhcpuser.net>
References: <f85e6be597ae30fd4dab776b924c0cd0a66514c0.1312314817.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?UTF-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:46056 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755376Ab1HBVOw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Aug 2011 17:14:52 -0400
In-Reply-To: <f85e6be597ae30fd4dab776b924c0cd0a66514c0.1312314817.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue,  2 Aug 2011 22:24:35 +0200 (CEST)
Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl> wrote:

> Here is a preliminary version of common RX path for network drivers. =
The idea
> is an extension to Eric Dumazet's patch introducing build_skb() (it's
> incorporated here for easier testing).
>=20
> Future plans:
>  - extend this API to devices which can do split buffer receives corr=
ectly
>    and use napi_gro_frags() instead;
>  - implement DaveM's idea of RX buffer handling (fill first, process
>    if buffers available) in parallel to my version (process first, re=
fill
>    later);
>  - get rid of indirect calls in fast path (process_buffer() and
>    add_buffer()) - ideas? inline netdev_rx_poll() and pass callback t=
o it?
>=20
> Version rebased on v3.0 is running succesfully on one laptop with r81=
69 on
> board since about a week. No problems showed up yet. For net-next thi=
s
> needs retesting because of changes in device reset handling.

1. Don't put #ifdef code in, just go with the new code.
2. Get rid of the inline on all those functions. Anything over 3 lines
   really shouldn't be inlined.
3. What is the performance difference (if any)?
