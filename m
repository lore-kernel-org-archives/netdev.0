From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: bad TSO performance in 2.6.9-rc2-BK
Date: Tue, 28 Sep 2004 15:15:39 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040928051539.GA11354@gondor.apana.org.au>
References: <20040923161141.4ea9be4c.davem@davemloft.net> <Pine.NEB.4.33.0409271416360.14606-100000@dexter.psc.edu> <20040927160411.22b44f48.davem@davemloft.net> <20040927233639.GA8333@gondor.apana.org.au> <20040927171356.6a59d039.davem@davemloft.net> <20040928003412.GA8755@gondor.apana.org.au> <20040927215901.6f65dc15.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jheffner@psc.edu, ak@suse.de, niv@us.ibm.com, andy.grover@gmail.com,
        anton@samba.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20040927215901.6f65dc15.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Sep 27, 2004 at 09:59:01PM -0700, David S. Miller wrote:
> 
> It's got a nasty bug though, I'm not updating
> TCP_SKB_CB(skb)->seq so retransmits have corrupted
> sequence numbers, doh!  And hey if I update that
> then I do not need this tso_offset thingy.

Nice work.

> +	if (skb->len != (data_end_seq - data_seq)) {

Please make that > so that I can sleep at night :)

> +		if (__tcp_trim_head(sk, skb, data_end_seq - data_seq))

The argument to __tcp_trim_head should be

skb->len - (data_end_seq - data_seq)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
