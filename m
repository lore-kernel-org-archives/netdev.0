From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fix corrupt TCP packets when options space overflows
 with MD5SIG enabled
Date: Sun, 01 Jun 2008 23:56:49 -0700 (PDT)
Message-ID: <20080601.235649.109450540.davem@davemloft.net>
References: <396556a20805301140x586093e5o92d44e38f7c2869a@mail.gmail.com>
	<396556a20805301217k293e5718h6bbf02bfe0683143@europa>
	<Xine.LNX.4.64.0806020938240.8594@us.intercode.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: agl@imperialviolet.org, netdev@vger.kernel.org
To: jmorris@namei.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41704
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752566AbYFBG4w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2008 02:56:52 -0400
In-Reply-To: <Xine.LNX.4.64.0806020938240.8594@us.intercode.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: James Morris <jmorris@namei.org>
Date: Mon, 2 Jun 2008 09:40:15 +1000 (EST)

> On Sat, 31 May 2008, Adam Langley wrote:
> 
> > When MD5 signatures are turned on we can end up with syntactically invalid
> > packets with a header length < 20 bytes. This is because tcp_header_size
> > overflows with 12 bytes of timestamp, 20 bytes of signature and > 8 bytes of
> > SACK option.
> > 
> > Since we can't fit any SACK blocks in the final 8 bytes of options space, and
> > the MD5 signature is more important, we disable including SACK, or even
> > advertising it, when MD5 is enabled.
> > 
> > Signed-off-by: Adam Langley <agl@imperialviolet.org>
> 
> Reviewed-by: James Morris <jmorris@namei.org>

After making some minor coding style fixups, I applied this
fix, thanks everyone.
