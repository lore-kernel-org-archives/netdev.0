From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 06/19] netfilter: nf_conntrack: use atomic64 for accounting counters
Date: Tue, 3 Jan 2012 12:01:27 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6D8AF28@saturn3.aculab.com>
References: <1324778255-2830-7-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: <pablo@netfilter.org>, <netfilter-devel@vger.kernel.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-class: urn:content-classes:message
In-Reply-To: <1324778255-2830-7-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 
>  		if (acct) {
> -			spin_lock_bh(&ct->lock);
> -			acct[CTINFO2DIR(ctinfo)].packets++;
> -			acct[CTINFO2DIR(ctinfo)].bytes += skb->len;
> -			spin_unlock_bh(&ct->lock);
> +			atomic64_inc(&acct[CTINFO2DIR(ctinfo)].packets);
> +			atomic64_add(skb->len,
&acct[CTINFO2DIR(ctinfo)].bytes);
>  		}

On a 32bit arch the two atomic64 operations require a locked
bus cycle each. The spin_unlock_bh() may not need one - so
the code may now be slower (modulo lock contention etc).

Probably worth caching &acct[CTINFO2DIR(ctinfo)] in a local,
the compiler probably can't do it itself.

	David


