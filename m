From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] ICMP: ICMP_MIB_OUTMSGS increment duplicated
Date: Wed, 16 Jan 2008 22:49:01 +1100
Message-ID: <E1JF6lR-0007sF-00@gondolin.me.apana.org.au>
References: <478DD57B.6020503@cn.fujitsu.com>
Cc: davem@davemloft.net, dlstevens@us.ibm.com, netdev@vger.kernel.org
To: wangchen@cn.fujitsu.com (Wang Chen)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:37175 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751595AbYAPLtW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jan 2008 06:49:22 -0500
In-Reply-To: <478DD57B.6020503@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wang Chen <wangchen@cn.fujitsu.com> wrote:
> In tree net-2.6.25, commit "96793b482540f3a26e2188eaf75cb56b7829d3e3"
> made a mistake.
> 
> In that patch, David L added a icmp_out_count() in ip_push_pending_frames(),
> remove icmp_out_count() from icmp_reply(). But he forgot to remove 
> icmp_out_count() from icmp_send() too.
> Since icmp_send and icmp_reply will call icmp_push_reply, which will call
> ip_push_pending_frames, a duplicated increment happened in icmp_send.

Actually having the icmp_out_count call in ip_push_pending_frames seems
inconsistent.  Having it there means that we count raw socket ICMP packets
too.  But we don't do that for any other protocol, e.g., raw UDP packets
don't get counted.

So was the inclusion of raw ICMP packets intentional?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
