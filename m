From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [NETLINK] periodically rehash table, why?
Date: Thu, 15 Mar 2007 11:07:51 +1100
Message-ID: <E1HRdVX-0003fS-00@gondolin.me.apana.org.au>
References: <877itju408.fsf@kruemel.my-eitzenberger.de>
Cc: netdev@vger.kernel.org
To: holger@my-eitzenberger.de (Holger Eitzenberger)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3716 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1422759AbXCOAH6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Mar 2007 20:07:58 -0400
In-Reply-To: <877itju408.fsf@kruemel.my-eitzenberger.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Holger Eitzenberger <holger@my-eitzenberger.de> wrote:
> 
> in nl_pid_hash_dilute() there is:
> 
>   if (unlikely(avg > 1) && nl_pid_hash_rehash(hash, 1))
>      return 1;
> 
>      if (unlikely(len > avg) && time_after(jiffies, hash->rehash_time)) {
>         nl_pid_hash_rehash(hash, 0);
>         return 1;
>      }
> 
> I don't see a reason why periodically rehashing might help in any way
> (without resizing).  Is there a reason for that?

It's to prevent attackers from guessing the hash secret and causing
hash chains to grow excessively.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
