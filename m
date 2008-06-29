From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] net: em_cmp.c use unaligned access helpers
Date: Sun, 29 Jun 2008 11:54:24 +0200
Message-ID: <20080629095424.GM20815@postel.suug.ch>
References: <1214428440.6908.1.camel@brick> <20080627.201649.95998057.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: harvey.harrison@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:33717 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751654AbYF2JyF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 29 Jun 2008 05:54:05 -0400
Content-Disposition: inline
In-Reply-To: <20080627.201649.95998057.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* David Miller <davem@davemloft.net> 2008-06-27 20:16
> From: Harvey Harrison <harvey.harrison@gmail.com>
> Date: Wed, 25 Jun 2008 14:14:00 -0700
> 
> > Both locations are loading a big-endian value in cpu-endianness.  The
> > be32/be16_to_cpu immediately afterwards seems suspect.
> > 
> > Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
> 
> Smells like a bug, Thomas can you take a close look at this?

It's not a bug, the u16|u32 pointed to by ptr can be at any offset in the
skb buffer and is not necessarly in big endian, it can be both. Only the
user knows so he has to specify a flag if the value should be converted
from be to cpu.

I think the code is correct, although it could be simplified to:

case TCF_EM_ALIGN_U16:
	if (!cmp_needs_transformation(cmp))
		val = get_unaligned_le16(ptr);
	else
		val = get_unaligned_be16(ptr);

I wasn't aware of these flags when I wrote the code initially.
