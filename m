From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Make netif_rx_ni preempt-safe
Date: Wed, 20 Oct 2004 10:00:09 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041020000009.GA17246@gondor.apana.org.au>
References: <1098230132.23628.28.camel@krustophenia.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel <linux-kernel@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        vda@port.imtp.ilyichevsk.odessa.ua, linux-kernel@gondor.apana.org.au,
        maxk@qualcomm.com, irda-users@lists.sourceforge.net,
        Linux Network Development <netdev@oss.sgi.com>,
        Alain Schroeder <alain@parkautomat.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Lee Revell <rlrevell@joe-job.com>
Content-Disposition: inline
In-Reply-To: <1098230132.23628.28.camel@krustophenia.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Oct 19, 2004 at 07:55:33PM -0400, Lee Revell wrote:
> 
> --- include/linux/netdevice.h~	2004-10-19 18:50:18.000000000 -0400
> +++ include/linux/netdevice.h	2004-10-19 18:51:01.000000000 -0400
> @@ -696,9 +696,11 @@
>   */
>  static inline int netif_rx_ni(struct sk_buff *skb)
>  {
> +       preempt_disable();
>         int err = netif_rx(skb);

This is broken on older compilers.
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
