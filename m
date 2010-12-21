From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] filter: optimize accesses to ancillary
 data
Date: Tue, 21 Dec 2010 12:30:25 -0800 (PST)
Message-ID: <20101221.123025.59692663.davem@davemloft.net>
References: <1292478328.2603.56.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57471
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752971Ab0LUU34 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Dec 2010 15:29:56 -0500
In-Reply-To: <1292478328.2603.56.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 16 Dec 2010 06:45:28 +0100

> We can translate pseudo load instructions at filter check time to
> dedicated instructions to speed up filtering and avoid one switch().
> libpcap currently uses SKF_AD_PROTOCOL, but custom filters probably use
> other ancillary accesses.
> 
> Note : I made the assertion that ancillary data was always accessed with
> BPF_LD|BPF_?|BPF_ABS instructions, not with BPF_LD|BPF_?|BPF_IND ones
> (offset given by K constant, not by K + X register)
> 
> On x86_64, this saves a few bytes of text :
> 
> # size net/core/filter.o.*
>    text	   data	    bss	    dec	    hex	filename
>    4864	      0	      0	   4864	   1300	net/core/filter.o.new
>    4944	      0	      0	   4944	   1350	net/core/filter.o.old
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks Eric.
