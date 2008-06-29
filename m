From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: Re: [PATCH] net: em_cmp.c use unaligned access helpers
Date: Sun, 29 Jun 2008 11:01:30 -0700
Message-ID: <1214762490.6037.9.camel@brick>
References: <1214428440.6908.1.camel@brick>
	 <20080627.201649.95998057.davem@davemloft.net>
	 <20080629095424.GM20815@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.180]:46901 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754619AbYF2SBd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Jun 2008 14:01:33 -0400
Received: by wa-out-1112.google.com with SMTP id j37so942578waf.23
        for <netdev@vger.kernel.org>; Sun, 29 Jun 2008 11:01:33 -0700 (PDT)
In-Reply-To: <20080629095424.GM20815@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2008-06-29 at 11:54 +0200, Thomas Graf wrote:
> * David Miller <davem@davemloft.net> 2008-06-27 20:16
> > From: Harvey Harrison <harvey.harrison@gmail.com>
> > Date: Wed, 25 Jun 2008 14:14:00 -0700
> > 
> > > Both locations are loading a big-endian value in cpu-endianness.  The
> > > be32/be16_to_cpu immediately afterwards seems suspect.
> > > 
> > > Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
> > 
> > Smells like a bug, Thomas can you take a close look at this?
> 
> It's not a bug, the u16|u32 pointed to by ptr can be at any offset in the
> skb buffer and is not necessarly in big endian, it can be both. Only the
> user knows so he has to specify a flag if the value should be converted
> from be to cpu.

OK, but be16/32_to_cpu is a no-op on be-arches, so there is a bug here on
big-endian machines as they won't switch it back, your simplified patch
is actually a bugfix in that case.

> 
> I think the code is correct, although it could be simplified to:
> 
> case TCF_EM_ALIGN_U16:
> 	if (!cmp_needs_transformation(cmp))
> 		val = get_unaligned_le16(ptr);
> 	else
> 		val = get_unaligned_be16(ptr);
> 
> I wasn't aware of these flags when I wrote the code initially.

I introduced them recently, your patch is probably applicable to
2.6.26 as a bugfix.

Reviewed-by: Harvey Harrison <harvey.harrison@gmail.com>


