From: "David S. Miller" <davem@redhat.com>
Subject: Re: PATCH: [SKBUFF] Introduce skb_set_link_header_offset(skb,
 offset)
Date: Tue, 5 Oct 2004 13:53:38 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041005135338.6f381fa1.davem@redhat.com>
References: <4162FF64.4050108@conectiva.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
In-Reply-To: <4162FF64.4050108@conectiva.com.br>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 05 Oct 2004 17:09:08 -0300
Arnaldo Carvalho de Melo <acme@conectiva.com.br> wrote:

> Hi David,
> 
> 	Please consider pulling from:
> 
> bk://kernel.bkbits.net/acme/sk_buff-2.4
> 
> 	Now there are 14 outstanding changesets in this tree.

Slow down. :-)

There are bugs in your earlier changesets which are going
to make it hard for me to pull this tree in.  Let's work
one or two changesets at a time, not 14 ok? :-)

First bug, in ChangeSet 1.2032, drivers/net/wireless/orinoco.c

You change "skb->mac.raw + ETH_ALEN" into
"eth_hdr(skb)->h_source".  That can't be right
since orinoco_spy_gather() expects a pointer for
that argument.

Same error in the drivers/net/wireless/wavelan.c change
in ChangeSet 1.2032, replacing skb->mac.raw (a pointer)
with eth_hdr(skb)->h_dest in the call to wv_packet_info.
And then "skb->mac.raw + WAVELAN_ADDR_SIZE" into
"eth_hdr(skb)->h_source" in the call to wl_spy_gather().

The same errors occur all the changes to
drivers/net/wireless/wavelan_cs.c of the same ChangeSet.

Please start to submit this stuff in smaller pieces and
fix the above bugs, thanks.
