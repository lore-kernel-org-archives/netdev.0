From: Patrick McHardy <kaber@trash.net>
Subject: Re: patch: tunnels not setting inputdev
Date: Sun, 02 Jan 2005 01:24:08 +0100
Message-ID: <41D73F28.3090206@trash.net>
References: <1104513392.1048.316.camel@jzny.localdomain>	 <41D5941C.8060001@trash.net> <1104523892.1047.338.camel@jzny.localdomain>	 <41D6CB87.8040205@trash.net> <1104622406.1049.450.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com,
        Wichert Akkerman <wichert@wiggy.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1104622406.1049.450.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal wrote:
> I want to understand the repurcasssions instead of blindly setting. Let
> users complain, thats why the printk exists. For example what does
> input_dev mean for netbios or a 802.3ad interface? You already saw one,
> xfrm, where there was no need to reset.

What's special about netbios ? For 802.3ad, I would expect input_dev
to hold the virtual device through which the packet entered the stack,
just what iptables -i would match. For xfrm - there is no need but its
also not wrong.

>>I can't see the problem with
>>redirected packets, just set skb->input_dev = skb->dev in
>>netif_receive_skb, this should have exactly the same effect as
>>setting it in the drivers or the mirred action.
> 
> in some cases the pointers are swapped. You cant just blindly
> set skb->input_dev = skb->dev at the input - that would be violating the
> intent; think reinjecting packets (and look at mirred as a sample of
> apps to come that do this).

I don't know your intent, but I assumed it was to match the incoming
interface as the networking stack sees it. Why would the pointers be
swapped ? Please give me an example. mirred does:

         skb2->dev = dev;
         skb2->input_dev = skb->dev;

So on input input_dev is the incoming interface of the original packet,
on output it is the outgoing interface of the original packet. Doesn't
make much sense to me, the original packet came the same way both times.

Regards
Patrick
