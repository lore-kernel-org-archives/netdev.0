From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH] Fix corrupt TCP packets when options space overflows
 with MD5SIG enabled
Date: Mon, 2 Jun 2008 09:40:15 +1000 (EST)
Message-ID: <Xine.LNX.4.64.0806020938240.8594@us.intercode.com.au>
References: <396556a20805301140x586093e5o92d44e38f7c2869a@mail.gmail.com>
 <396556a20805301217k293e5718h6bbf02bfe0683143@europa>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Adam Langley <agl@imperialviolet.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from namei.org ([69.55.235.186]:46544 "EHLO us.intercode.com.au"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752391AbYFAXkU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 1 Jun 2008 19:40:20 -0400
In-Reply-To: <396556a20805301217k293e5718h6bbf02bfe0683143@europa>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 31 May 2008, Adam Langley wrote:

> When MD5 signatures are turned on we can end up with syntactically invalid
> packets with a header length < 20 bytes. This is because tcp_header_size
> overflows with 12 bytes of timestamp, 20 bytes of signature and > 8 bytes of
> SACK option.
> 
> Since we can't fit any SACK blocks in the final 8 bytes of options space, and
> the MD5 signature is more important, we disable including SACK, or even
> advertising it, when MD5 is enabled.
> 
> Signed-off-by: Adam Langley <agl@imperialviolet.org>

Reviewed-by: James Morris <jmorris@namei.org>


(FYI, the upcoming replacement for this, TCP-AO, is designed to be SACK 
compatible)


-- 
James Morris
<jmorris@namei.org>
