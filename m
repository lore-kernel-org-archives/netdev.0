From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] sky2: skb recycling
Date: Tue, 21 Oct 2008 07:54:18 +0200
Message-ID: <48FD6E8A.6060304@cosmosbay.com>
References: <20081020190922.7dd6510a@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp28.orange.fr ([80.12.242.100]:23173 "EHLO smtp28.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751764AbYJUFyb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Oct 2008 01:54:31 -0400
In-Reply-To: <20081020190922.7dd6510a@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger a =E9crit :
> Add support for recycling tx buffers into receive buffers.
> This is experimental at this point.
>=20

I really like this skb recycling

=46or best performance, driver should perform TX completion before RX c=
ompletion, so that
freshly added skb in recycle queue have a chance being reused right aft=
er. Apparently sky2
tx handling is finegrained (events posted by NIC)

But still, this mechanism also use more skbs per device, especially on =
dormant ones.

If your RX ring has 256 skb, then adding the recycle queue can adds 256=
 more skbs... One MB or event more...

Maybe we should flush the recycle queue, every 5 seconds or so, especia=
lly if device is dormant
(no RX on it, litle heartbeat TX)





