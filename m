From: David Miller <davem@davemloft.net>
Subject: Re: [TCP_CA_CWR] Causes for entering TCP_CA_CWR state with 0
 retransmissions
Date: Tue, 14 Jul 2009 12:15:28 -0700 (PDT)
Message-ID: <20090714.121528.15246520.davem@davemloft.net>
References: <46bf9ede0907141138q3b665aefv46a18591c3cfc2ce@mail.gmail.com>
	<20090714.114211.254914419.davem@davemloft.net>
	<46bf9ede0907141212x7a7a84f8l1882ffefbaf21e14@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yinglinsun@cs.pitt.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37247
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755648AbZGNTPY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jul 2009 15:15:24 -0400
In-Reply-To: <46bf9ede0907141212x7a7a84f8l1882ffefbaf21e14@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yinglin Sun <yinglinsun@cs.pitt.edu>
Date: Tue, 14 Jul 2009 15:12:16 -0400

> I use the total number of retransmissions reported by tcp_info. The
> field name is tcpi_total_retrans. From the kernel source code, I found
> that this number is for both fast retransmit and timeout
> retransmissions. On the other hand, if fast retransmission happened,
> ca_state should be TCP_CA_Recovery or TCP_CA_Disorder, but it's
> TCP_CA_CWR.

Great, that if you're reading the code you also see that there
are many code paths that invoke tcp_enter_cwr() that can occur
without any retransmissions. :-)

One such case is when ECN congestion notification bits are
seen in an ACK packet.
