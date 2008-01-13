From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 0/3] bonding: 3 fixes for 2.6.24
Date: Sun, 13 Jan 2008 11:19:41 +1100
Message-ID: <E1JDqZh-0002IH-00@gondolin.me.apana.org.au>
References: <18609.1200160598@death>
Cc: olel@ans.pl, andy@greyhouse.net, netdev@vger.kernel.org,
	jgarzik@pobox.com, davem@davemloft.net, herbert@gondor.apana.org.au
To: fubar@us.ibm.com (Jay Vosburgh)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2603 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751658AbYAMAUG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Jan 2008 19:20:06 -0500
In-Reply-To: <18609.1200160598@death>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jay Vosburgh <fubar@us.ibm.com> wrote:
> 
>        Can you test the following and let me know if it triggers the
> warning?  I believe this is the minimum locking needed, and based on
> input from Herbert, we shouldn't need to hold the lock at _bh.  If this
> one works, and nobody sees any other issues with it, then it's the final
> patch for this lockdep problem.  I'll add some deep, meaningful comments
> to explain the locking a bit (i.e., we're called with rtnl for the
> allmulti and promisc cases, so we're ok there without additional locks,
> but the later code could be called from anywhere, so it needs locks to
> prevent the slave list from changing, but the mc_lists themselves are
> covered by the netif_tx_lock that all callers will hold), but this would
> be the actual code change.

I just had a look at the bonding code and while I didn't find anything
wrong with the change of the write lock to a read lock, the mc_list
itself does not seem to have adequete protection.  In particular, there
doesn't seem to be anything protecting the walking of mc_list in
bond_enslave.

This could be a problem if we have an IGMP6 event triggering the change
in the master's mc_list.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
