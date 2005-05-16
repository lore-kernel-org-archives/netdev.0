From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Fw: [Bugme-new] [Bug 4628] New: Test server hang while running rhr (network) test on RHEL4 with kernel 2.6.12-rc1-mm4
Date: Mon, 16 May 2005 21:00:50 +1000
Message-ID: <E1DXdL8-0005mE-00@gondolin.me.apana.org.au>
References: <20050516025901.4b26ccf3.akpm@osdl.org>
Cc: netdev@oss.sgi.com, hejianj@cn.ibm.com,
        linuxppc64-dev@lists.linuxppc.org.sgi.com, anton@samba.org,
        jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: akpm@osdl.org (Andrew Morton)
In-Reply-To: <20050516025901.4b26ccf3.akpm@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Andrew Morton <akpm@osdl.org> wrote:
> 
> Might be a bug in the e100 driver, might not be.
> 
> I assume this is the
> 
>        BUG_ON(skb->list != NULL);

It certainly is a bug in e100.

e100_tx_timeout -> e100_down -> e100_rx_clean_list

is racing against

e100_poll -> e100_rx_clean -> e100_rx_indicate

e100_rx_clean/e100_rx_indicate takes an skb off the RX ring and
while it's being processed e100_rx_clean_list comes along and
frees it.

>From a quick check similar problems may exist in other drivers that
have lockless ->poll() functions with RX rings.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
