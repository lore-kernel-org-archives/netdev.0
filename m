From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: [PATCH] net: pfifo_fast - use ffs(x)-1 instead of array lookup
Date: Tue, 13 Mar 2012 10:34:23 -0700
Message-ID: <1331660063.4449.23.camel@edumazet-glaptop>
References: <AE90C24D6B3A694183C094C60CF0A2F6026B6EA1@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Maciej Zenczykowski <zenczykowski@gmail.com>,
	Maciej Zenczykowski <maze@google.com>, netdev@vger.kernel.org
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:38238 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758059Ab2CMRe0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Mar 2012 13:34:26 -0400
Received: by yenl12 with SMTP id l12so803925yen.19
        for <netdev@vger.kernel.org>; Tue, 13 Mar 2012 10:34:26 -0700 (PDT)
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B6EA1@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-03-13 at 16:55 +0000, David Laight wrote:
> > > +	/* For i in 0..7 returns {-1, 0, 1, 0, 2, 0, 1, 0}[i] */
> > > +	return ((26468 >> (i+i)) & 3) - 1;
> > 
> > That expression doesn't seem quite right to me ...
> > 	return (int)(0x12131210 >> (i * 4)) & 3) - 1;
> > probably does whats wanted.
> 
> Hmmm... I'm going blind - I read that as 'i+1' not 'i+i'.
> But using 'i * 4' and putting the constant in base 16
> make the code rather less obscure.

Point was to get short/fast code.

26458 can probably be expressed with a macro so that it is self
explained.

Check asm output if your way is better. Its probably not the case
because some arches can use smaller code to manipulate small constants.

I am not sure the memory lookup is that expensive anyway
(we probably could use 'char' instead of 'int' to reduce the siwe of
this memory blob)

Code is also read from memory, so you have to trade icache/dcache
issues.
