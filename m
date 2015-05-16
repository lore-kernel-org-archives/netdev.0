From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: netlink: Kill bogus lock_sock in netlink_insert
Date: Sat, 16 May 2015 20:32:42 +0800
Message-ID: <20150516123242.GA683@gondor.apana.org.au>
References: <20150514042151.GA5482@gondor.apana.org.au>
 <20150514055824.GB6058@gondor.apana.org.au>
 <20150514060230.GD6058@gondor.apana.org.au>
 <20150515.130219.331336809636676892.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, tgraf@suug.ch, netdev@vger.kernel.org,
	ying.xue@windriver.com
To: David Miller <davem@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:57794 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755099AbbEPMcy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 May 2015 08:32:54 -0400
Content-Disposition: inline
In-Reply-To: <20150515.130219.331336809636676892.davem@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 15, 2015 at 01:02:19PM -0400, David Miller wrote:
>
> Actually, Herbert, I think this lock_sock() is needed.
> 
> Otherwise nothing protects nlk_sk(sk)->portid, upon which we
> perform a non-atomic test-and-set operation here.
> 
> If you remove the lock_sock(), two parallel bind/inserts are
> possible on the same socket, potentially resulting in socket
> state corruption.

You're quite right.  I forgot about that case.

However, the code as is still buggy because it fails to reset
portid when our auto-allocated portid collides with somebody
else, resulting in a bogus bind failure.

I'll fix that up too in a new patch.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
