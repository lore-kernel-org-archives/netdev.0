From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Yet another bridge netfilter crash
Date: Tue, 10 Aug 2010 11:19:19 -0400
Message-ID: <20100810151919.GA30450@gondor.apana.org.au>
References: <20100723134208.GA6655@gondor.apana.org.au> <4C49A4C6.4070503@trash.net> <20100723150041.GA7301@gondor.apana.org.au> <4C49B296.10009@trash.net> <20100723152609.GA7576@gondor.apana.org.au> <4C5995C2.1010909@trash.net> <20100804164119.GA6256@gondor.apana.org.au> <4C599A6A.6050202@trash.net> <20100809214254.GA23824@gondor.apana.org.au> <AANLkTikpCOrkPqOkahXBFFoH6bqTKhA-+_mUy0qGrRnq@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:49699 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932129Ab0HJPT0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Aug 2010 11:19:26 -0400
Content-Disposition: inline
In-Reply-To: <AANLkTikpCOrkPqOkahXBFFoH6bqTKhA-+_mUy0qGrRnq@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 10, 2010 at 06:39:42AM +0800, Changli Gao wrote:
>
> How about always using the skb->nf_bridge of the skb last received in
> a defrag queue as the nf_bridge of the final defraged skb? I have
> posted a patch doing such thing.
> http://patchwork.ozlabs.org/patch/60904/

I'd rather just drop the fragment (and maybe fail the whole
reassembly) if you detect nf_bridge mismatches.

Reassembling fragments from two interfaces is one thing, but
knowingly reassembling fragments across two bridges is just
wrong.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
