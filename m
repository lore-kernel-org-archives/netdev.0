From: Patrick McHardy <kaber@trash.net>
Subject: Re: patch: tunnels not setting inputdev
Date: Fri, 31 Dec 2004 19:02:04 +0100
Message-ID: <41D5941C.8060001@trash.net>
References: <1104513392.1048.316.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com,
        Wichert Akkerman <wichert@wiggy.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1104513392.1048.316.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal wrote:
> Dave,
> 
> Patch attached that has tunnels setting input dev correctly. 
> 
> Incorporates what ive sent to Wichert already.
> 
> A lot of the stuff the tunnels do is very similar, so maybe wiser to
> have something like tunnel_type_trans().
> 
> cheers,
> jamal
> 
> 
> ------------------------------------------------------------------------
> 
> --- 2610-bk1/net/ipv4/xfrm4_input.c	2004/12/31 17:00:25	1.1
> +++ 2610-bk1/net/ipv4/xfrm4_input.c	2004/12/31 17:01:05
> @@ -142,6 +142,7 @@
>  			dst_release(skb->dst);
>  			skb->dst = NULL;
>  		}
> +		skb->input_dev = skb->dev;

This is not necessary, xfrm4_input doesn't change anything
regarding devices, so if it was correct before, it is still
correct. For the remaining changes, why not simply set
input_dev in netif_receive_skb before the call to ing_filter ?


>  		netif_rx(skb);
>  		return 0;
>  	} else {

Another question - why is ing_filter exported when
CONFIG_NET_CLS_ACT is defined ? Nobody uses it currently
outside of dev.c.

Regards
Patrick
