From: Bastian Blank <bastian@waldi.eu.org>
Subject: Re: [patch 1/5] [PATCH] qeth: HiperSockets SIGA retry support on
	CC=2.
Date: Thu, 27 Aug 2009 09:05:47 +0200
Message-ID: <20090827070547.GA32106@wavehammer.waldi.eu.org>
References: <20090826120105.727838000@de.ibm.com> <20090826120135.998746000@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org,
	Klaus-Dieter Wacker <kdwacker@de.ibm.com>
To: frank.blaschka@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from wavehammer.waldi.eu.org ([82.139.201.20]:54137 "EHLO
	wavehammer.waldi.eu.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751336AbZH0HPU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Aug 2009 03:15:20 -0400
Content-Disposition: inline
In-Reply-To: <20090826120135.998746000@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 26, 2009 at 02:01:06PM +0200, frank.blaschka@de.ibm.com wrote:
> Qeth HiperSockets support now retries sending of packets when the
> IBM System z signals a temporary resource shortage (e.g. target
> buffer full). The packet is enqueued into the device queue.
> After 3 times of unsuccessful send the packet is dropped.

What is the reason for that? How large is the timeout for each retry?
Usually the upper layers should already handle dropped packages fine and
adding another retry below can produce retry multiplication.

> @@ -3178,6 +3203,25 @@ int qeth_do_send_packet_fast(struct qeth
>  	atomic_set(&queue->state, QETH_OUT_Q_UNLOCKED);
>  	qeth_fill_buffer(queue, buffer, skb, hdr, offset, hd_len);
>  	qeth_flush_buffers(queue, index, 1);
> +	if (queue->sync_iqdio_error == 2) {

Is this a magic constant?

Bastian

-- 
... The prejudices people feel about each other disappear when they get
to know each other.
		-- Kirk, "Elaan of Troyius", stardate 4372.5
