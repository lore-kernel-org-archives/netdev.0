From: Tony Battersby <tonyb@cybernetics.com>
Subject: Re: TG3 network data corruption regression 2.6.24/2.6.23.4
Date: Tue, 15 Apr 2008 11:39:27 -0400
Message-ID: <4804CC2F.6030403@cybernetics.com>
References: <47BA0984.2070306@cybernetics.com> <1203381120.13495.78.camel@dell> <20080218.163554.74130592.davem@davemloft.net> <1203383046.13495.87.camel@dell> <47BB00EC.3010607@cybernetics.com> <1203448265.13495.95.camel@dell> <47BB54C2.6090501@cybernetics.com> <20080220034515.GC22703@gondor.apana.org.au> <47BC44E2.9060301@cybernetics.com> <20080415001207.GA11852@localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Michael Chan <mchan@broadcom.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, gregkh@suse.de,
	linux-kernel@vger.kernel.org
To: Matt Carlson <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from host64.cybernetics.com ([70.169.137.4]:4582 "EHLO
	mail.cybernetics.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750958AbYDOQGr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Apr 2008 12:06:47 -0400
In-Reply-To: <20080415001207.GA11852@localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Matt Carlson wrote:
> Hi Tony.  Sorry for the radio silence.
>
> Michael and I have discussed this problem a bit.  Another possibility is
> that the chip may be having difficulty with non-dword aligned TX buffers.
> Since we already know the RX side has the same problem, it isn't so
> far-fetched to think that perhaps it can affect the TX side too.  Can
> you give the following patch a try and see if the corruption still
> happens?
>
>   

Thanks, your patch fixes the problem (tested on 2.6.24.4).  However, I
had to change "(skb->mac_header & 3)" in your patch to "((long)
skb->mac_header & 3)" since mac_header is a pointer rather than an int
on 32-bit systems.

Tested-by: Tony Battersby <tonyb@cybernetics.com>

