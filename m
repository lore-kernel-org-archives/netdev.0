From: Patrick McHardy <kaber@trash.net>
Subject: Re: 2.6.20 crash in tcp_tso_segment()
Date: Tue, 13 Feb 2007 15:34:43 +0100
Message-ID: <45D1CC83.8080603@trash.net>
References: <E1HFc6X-0006n7-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Mike Accetta <maccetta@laurelnetworks.com>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:37619 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750804AbXBMOeq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Feb 2007 09:34:46 -0500
In-Reply-To: <E1HFc6X-0006n7-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> Mike Accetta <maccetta@laurelnetworks.com> wrote:
> 
>>Obviously the code believes it can assume that there are always multiple
>>sk_buff's in the chain.  The stack trace seems to implicate iptables in
>>the scenario (twice) if that means anything.  Any ideas about what may
>>be going wrong here?  There is indeed a private module loaded at the time
>>but it does no networking and I doubt it is the culprit.
> 
> 
> Yeah we should never get here if we only have one segment.
> Could you get it to print out the value of skb->gso_*?

The callpath shows the REJECT target sending a TCP reset.
I'm guessing it has something to do with skb_copy_expand
copying the gso fields.

