From: Patrick McHardy <kaber@trash.net>
Subject: Re: patch: tunnels not setting inputdev
Date: Sat, 01 Jan 2005 17:10:47 +0100
Message-ID: <41D6CB87.8040205@trash.net>
References: <1104513392.1048.316.camel@jzny.localdomain>	 <41D5941C.8060001@trash.net> <1104523892.1047.338.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com,
        Wichert Akkerman <wichert@wiggy.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1104523892.1047.338.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal wrote:

>>For the remaining changes, why not simply set
>>input_dev in netif_receive_skb before the call to ing_filter ?
> 
> You want to be able to filter on indev at ingress - it is safer for
> whoever calls netif_rx() to do the setting. The packet could be looped
> from egress multiple times as well (redirected).

Currently input_dev is set in eth_type_trans, ppp_generic and the
mirred action. With your patch we have a couple of drivers more,
but this still leaves lots of non-ethernet drivers that don't set
input_dev. A centralized solutions seems much better to me than
adding this to every single driver. I can't see the problem with
redirected packets, just set skb->input_dev = skb->dev in
netif_receive_skb, this should have exactly the same effect as
setting it in the drivers or the mirred action.

Regards
Patrick
