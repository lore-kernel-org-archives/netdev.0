From: jamal <hadi@cyberus.ca>
Subject: Re: patch: tunnels not setting inputdev
Date: 31 Dec 2004 15:11:32 -0500
Message-ID: <1104523892.1047.338.camel@jzny.localdomain>
References: <1104513392.1048.316.camel@jzny.localdomain>
	 <41D5941C.8060001@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com,
        Wichert Akkerman <wichert@wiggy.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <41D5941C.8060001@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2004-12-31 at 13:02, Patrick McHardy wrote:
> jamal wrote:

> > --- 2610-bk1/net/ipv4/xfrm4_input.c	2004/12/31 17:00:25	1.1
> > +++ 2610-bk1/net/ipv4/xfrm4_input.c	2004/12/31 17:01:05
> > @@ -142,6 +142,7 @@
> >  			dst_release(skb->dst);
> >  			skb->dst = NULL;
> >  		}
> > +		skb->input_dev = skb->dev;
> 
> This is not necessary, xfrm4_input doesn't change anything
> regarding devices, so if it was correct before, it is still
> correct. 

Same logic can apply to xfrm6_input then - since both are not exactly
tunnels. I didnt check the code path - iam gonna assume you are right
and kill those two.

> For the remaining changes, why not simply set
> input_dev in netif_receive_skb before the call to ing_filter ?
> 

You want to be able to filter on indev at ingress - it is safer for
whoever calls netif_rx() to do the setting. The packet could be looped
from egress multiple times as well (redirected).

> >  		netif_rx(skb);
> >  		return 0;
> >  	} else {
> 
> Another question - why is ing_filter exported when
> CONFIG_NET_CLS_ACT is defined ? Nobody uses it currently
> outside of dev.c.

Go ahead kill it there and in net/pkt_cls.h

cheers,
jamal
