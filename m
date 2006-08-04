From: Patrick McHardy <kaber@trash.net>
Subject: Re: [XFRM]: Improve MTU estimation
Date: Fri, 04 Aug 2006 13:11:19 +0200
Message-ID: <44D32B57.2000304@trash.net>
References: <44D30A48.4050403@trash.net> <44D312EF.8010202@trash.net> <20060804100121.GA17239@gondor.apana.org.au> <44D31CCE.7020301@trash.net> <20060804101345.GA17583@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Kernel Netdev Mailing List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:40916 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S1751437AbWHDLNO
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Aug 2006 07:13:14 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20060804101345.GA17583@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> On Fri, Aug 04, 2006 at 12:09:18PM +0200, Patrick McHardy wrote:
> 
>>I was wondering why the old code distinguished between transport mode
>>and tunnel mode, I couldn't spot anything that would be affected. I'll
>>look into the transport mode case again.
> 
> 
> The problem is basically you don't know a priori the size of the IP
> options.  So you assume the worst case where the IP options causes
> the largest amount of padding for encryption (IP option length itself
> must be a multiple of 4, so for a block size of 8 the worst is 4,
> and the worst is 12 for a block size of 16).
> 
> Of course it gets hairier if you have ESP padding.  I'm not even sure
> if the current code gets that right.


Unless I'm missing something, the padding caused by IP options
is always less than the worst case that can happen anyway
(max(block size, padlen)-1), so it can simply be ignored.

