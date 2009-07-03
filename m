From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: tun netns BUG()
Date: Fri, 3 Jul 2009 23:25:47 +0800
Message-ID: <20090703152547.GA28755@gondor.apana.org.au>
References: <m163e9hl8x.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, dwmw2@infradead.org, netdev@vger.kernel.org,
	johannes@sipsolutions.net
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:38685 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753410AbZGCPZx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jul 2009 11:25:53 -0400
Content-Disposition: inline
In-Reply-To: <m163e9hl8x.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric W. Biederman <ebiederm@xmission.com> wrote:
> 
> Not so.
> 
> unregister_netdevice
>  rollback_registered
>    tun_net_unit
>      __tun_detach.
> 
> 
> Further we need rtnl_lock around __tun_detach.

No we don't, tfile->count prevents this from occuring.  The async
path will only __tun_detach if the count hits zero, in which case
the first if clause in tun_chr_close will fail.  Conversely, if
we're in the first if clause in tun_chr_close, then the async
path either didn't execute at all or did not call __tun_detach.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
