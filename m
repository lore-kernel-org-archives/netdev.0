From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fix corrupt TCP packets when options space overflows
 with MD5SIG enabled
Date: Tue, 03 Jun 2008 09:44:00 -0700 (PDT)
Message-ID: <20080603.094400.267474563.davem@davemloft.net>
References: <396556a20805301217k293e5718h6bbf02bfe0683143@europa>
	<Xine.LNX.4.64.0806020938240.8594@us.intercode.com.au>
	<396556a20806030931s9e8ec42hba9e39d9fe3514f1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jmorris@namei.org, netdev@vger.kernel.org
To: agl@imperialviolet.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49104
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751918AbYFCQoG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 12:44:06 -0400
In-Reply-To: <396556a20806030931s9e8ec42hba9e39d9fe3514f1@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Adam Langley" <agl@imperialviolet.org>
Date: Tue, 3 Jun 2008 09:31:02 -0700

> It looks, on second glance, that this code in
> tcp_build_and_update_options will include the options even though we
> calculated the size without:
> 
> if (tp->rx_opt.eff_sacks) {
> 	struct tcp_sack_block *sp = tp->rx_opt.dsack ? tp->duplicate_sack :
> tp->selective_acks;
> 	int this_sack;
> 
> 	*ptr++ = htonl((TCPOPT_NOP  << 24) |
> 		       (TCPOPT_NOP  << 16) |
> 		       (TCPOPT_SACK <<  8) |
> 		       (TCPOLEN_SACK_BASE + (tp->rx_opt.eff_sacks *
> 			     TCPOLEN_SACK_PERBLOCK)));
> ...
> 
> Unless I'm missing something, that patch was incomplete and we're
> still sending invalid packets on in the MD5SIG + SACK case.

That's right, the code assumes there is always enough space for
the SACK blocks.
