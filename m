From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: Re: PATCH: [SKBUFF] Introduce skb_set_link_header_offset(skb, offset)
Date: Tue, 05 Oct 2004 18:25:09 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <41631135.5040609@conectiva.com.br>
References: <4162FF64.4050108@conectiva.com.br> <20041005135338.6f381fa1.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20041005135338.6f381fa1.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> On Tue, 05 Oct 2004 17:09:08 -0300
> Arnaldo Carvalho de Melo <acme@conectiva.com.br> wrote:
> 
> 
>>Hi David,
>>
>>	Please consider pulling from:
>>
>>bk://kernel.bkbits.net/acme/sk_buff-2.4
>>
>>	Now there are 14 outstanding changesets in this tree.
> 
> 
> Slow down. :-)

Oh, flow control! :-)

> 
> There are bugs in your earlier changesets which are going
> to make it hard for me to pull this tree in.  Let's work
> one or two changesets at a time, not 14 ok? :-)
> 
> First bug, in ChangeSet 1.2032, drivers/net/wireless/orinoco.c
> 
> You change "skb->mac.raw + ETH_ALEN" into
> "eth_hdr(skb)->h_source".  That can't be right
> since orinoco_spy_gather() expects a pointer for
> that argument.
> 
> Same error in the drivers/net/wireless/wavelan.c change
> in ChangeSet 1.2032, replacing skb->mac.raw (a pointer)
> with eth_hdr(skb)->h_dest in the call to wv_packet_info.

humm, puzzled, isn't eth_hdr(skb)->h_dest a pointer of the
same tipe (unsigned char *), that points to same place as
skb->mac.raw? :-)

But perhaps the guy wanted the whole link header, I got
confused because afterwards it uses the ETH_ALEN offset,
meaning that it wanted now the second struct ethhdr field,

lemme look again at this code...

Nope, you're right, seems to be the 802.11 three adresses stuff,
done in an ad-hoc confusing way, my mistake.

> Please start to submit this stuff in smaller pieces and
> fix the above bugs, thanks.

mmkay sir!

Best Regards,

- Arnaldo
