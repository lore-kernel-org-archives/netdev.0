From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Make netif_rx_ni preempt-safe
Date: Thu, 21 Oct 2004 10:35:03 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041021003503.GA10391@gondor.apana.org.au>
References: <1098230132.23628.28.camel@krustophenia.net> <200410202256.56636.vda@port.imtp.ilyichevsk.odessa.ua> <1098303951.2268.8.camel@krustophenia.net> <200410202332.33583.vda@port.imtp.ilyichevsk.odessa.ua> <20041020171508.0e947d08.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>, rlrevell@joe-job.com,
        akpm@osdl.org, linux-kernel@vger.kernel.org,
        linux-kernel@gondor.apana.org.au, maxk@qualcomm.com,
        irda-users@lists.sourceforge.net, netdev@oss.sgi.com,
        alain@parkautomat.net
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20041020171508.0e947d08.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Oct 20, 2004 at 05:15:08PM -0700, David S. Miller wrote:
>  
> +int netif_rx_ni(struct sk_buff *skb)
> +{
> +       int err = netif_rx(skb);
> +
> +       preempt_disable();
> +       if (softirq_pending(smp_processor_id()))
> +               do_softirq();

You need to move the netif_rx call inside the disable as otherwise
you might be checking the pending flag on the wrong CPU.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
