From: jamal <hadi@cyberus.ca>
Subject: Re: patch: tunnels not setting inputdev
Date: 01 Jan 2005 18:33:27 -0500
Message-ID: <1104622406.1049.450.camel@jzny.localdomain>
References: <1104513392.1048.316.camel@jzny.localdomain>
	 <41D5941C.8060001@trash.net> <1104523892.1047.338.camel@jzny.localdomain>
	 <41D6CB87.8040205@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com,
        Wichert Akkerman <wichert@wiggy.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <41D6CB87.8040205@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 2005-01-01 at 11:10, Patrick McHardy wrote:
> jamal wrote:
> 
> >>For the remaining changes, why not simply set
> >>input_dev in netif_receive_skb before the call to ing_filter ?
> > 
> > You want to be able to filter on indev at ingress - it is safer for
> > whoever calls netif_rx() to do the setting. The packet could be looped
> > from egress multiple times as well (redirected).
> 
> Currently input_dev is set in eth_type_trans, ppp_generic and the
> mirred action. With your patch we have a couple of drivers more,

I want to understand the repurcasssions instead of blindly setting. Let
users complain, thats why the printk exists. For example what does
input_dev mean for netbios or a 802.3ad interface? You already saw one,
xfrm, where there was no need to reset. 

> but this still leaves lots of non-ethernet drivers that don't set
> input_dev. A centralized solutions seems much better to me than
> adding this to every single driver.

Ethernet like, ppp-like and now tunnel-like. If you note on my email
with the patch i said: 
"A lot of the stuff the tunnels do is very similar, so maybe wiser to
have something like tunnel_type_trans()."
This includes things like nf_reset(skb) which is done by that family of
devices that may need centralizing.
If you want to create such a patch go ahead and i will hold mine.

> I can't see the problem with
> redirected packets, just set skb->input_dev = skb->dev in
> netif_receive_skb, this should have exactly the same effect as
> setting it in the drivers or the mirred action.
> 

in some cases the pointers are swapped. You cant just blindly
set skb->input_dev = skb->dev at the input - that would be violating the
intent; think reinjecting packets (and look at mirred as a sample of
apps to come that do this).

cheers,
jamal
