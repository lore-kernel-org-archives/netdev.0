From: "David S. Miller" <davem@redhat.com>
Subject: Re: tunnel xmit and h.raw
Date: Fri, 3 Oct 2003 08:04:44 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031003080444.173a403c.davem@redhat.com>
References: <20031003073039.7ca1a76c.davem@redhat.com>
	<Pine.LNX.4.44.0310031750390.2761-100000@l>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Julian Anastasov <ja@ssi.bg>
In-Reply-To: <Pine.LNX.4.44.0310031750390.2761-100000@l>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 3 Oct 2003 17:56:35 +0300 (EEST)
Julian Anastasov <ja@ssi.bg> wrote:

> On Fri, 3 Oct 2003, David S. Miller wrote:
> 
> > Didn't we fix a nearly identical set of bugs in the tunnel
> > drivers just a month or two ago?
> 
> 	The same place, but this one is special: h.raw is updated
> for us on reallocation but if the skb is shared I do not know if this is
> fatal for the other skb users, we change also their h.raw. But I rely
> on your opinion, may be it is safer with this change.

Oh, I see, the code is actually not buggy as-is.  The following two
sequences are identical:

1)	skb->h.raw = skb->nh.raw;
	new_skb = skb_realloc_headroom(...);
	skb = new_skb;

2)	new_skb = skb_realloc_headroom(...);
	skb = new_skb;
	skb->h.raw = skb->nh.raw;

Because skb_realloc_headroom() keeps all the skb->*.raw pointers
in the right relative place if it allocates new data pointers or
whatever.

But the code is certainly clearer to read with your changes so I'll
add them as a code cleanup instead of a bug fix :)
