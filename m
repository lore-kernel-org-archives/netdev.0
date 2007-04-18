From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: kernel BUG at net/core/skbuff.c in linux-2.6.21-rc6
Date: Thu, 19 Apr 2007 07:35:47 +1000
Message-ID: <E1HeHoZ-0000Y6-00@gondolin.me.apana.org.au>
References: <17953.30429.220756.818283@cargo.ozlabs.ibm.com>
Cc: davem@davemloft.net, kaber@trash.net, poemann@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: paulus@samba.org (Paul Mackerras)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1701 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S2992815AbXDRVhG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Apr 2007 17:37:06 -0400
In-Reply-To: <17953.30429.220756.818283@cargo.ozlabs.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Paul:

Paul Mackerras <paulus@samba.org> wrote:
> 
> So this doesn't change process_input_packet(), which treats the case
> where the first byte is 0xff (PPP_ALLSTATIONS) but the second byte is
> 0x03 (PPP_UI) as indicating a packet with a PPP protocol number of
> 0xff.  Arguably that's wrong since PPP protocol 0xff is reserved, and
> the RFC does envision the possibility of receiving frames where the
> control field has values other than 0x03.

Your fix is probably needed too.  However, I think the issue that Patrick
was trying to fix is the case where p[0] != PPP_ALLSTATIONS and therefore
we'd still have a problem there.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
