From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Allowing netlink_family to be any integer (was: [PATCH 2.6] iptables CLUSTERIP target)
Date: Fri, 22 Oct 2004 07:31:07 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E1CKkWZ-0005x5-00@gondolin.me.apana.org.au>
References: <20041021142527.GG3551@sunbeam.de.gnumonks.org>
Cc: lmb@suse.de, ahu@ds9a.nl, hch@infradead.org, netdev@oss.sgi.com,
        davem@davemloft.net
Return-path: <netdev-bounce@oss.sgi.com>
To: laforge@netfilter.org (Harald Welte)
In-Reply-To: <20041021142527.GG3551@sunbeam.de.gnumonks.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Harald Welte <laforge@netfilter.org> wrote:
>
> For supporting two primitive operation, adding a new netlink address
> family also isn't worthwhile, especially since we're short of netlink
> families.

That's something I'm looking into as well.  The current strategy of
either creating a new family or tacking random things into RTNETLINK
is simply not going to scale.

Initially I considered an interface where kernel users can register
themselves using a string as the key.  But I soon realised that we
could simply allow the netlink_family field to be an arbitrary integer
that is used as a key to a hash table.

The CPU cost of the hash table isn't too bad since you'll only be
looking it up when the socket is created.

Comments anyone?
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
