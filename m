From: "David S. Miller" <davem@redhat.com>
Subject: Re: Allow IP header alignment to be overriden
Date: Sat, 12 Jun 2004 11:12:18 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040612111218.783f587d.davem@redhat.com>
References: <20040611012727.GA27672@krispykreme>
	<20040610223549.5e9ad025.davem@redhat.com>
	<1086939562.3657.10.camel@sfeldma-mobl2.dsl-verizon.net>
	<20040611142336.GE27672@krispykreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: sfeldma@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Anton Blanchard <anton@samba.org>
In-Reply-To: <20040611142336.GE27672@krispykreme>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 12 Jun 2004 00:23:37 +1000
Anton Blanchard <anton@samba.org> wrote:

> Would creating:
> 
> /* 
>  * Network drivers want to align IP headers. Since we have 14 bytes of
>  * ethernet header, adding 2 bytes will align the IP header.  However
>  * this will mean we do unaligned DMA so there is a trade off.
>  *
>  * We allow this to be overridden per arch as the unaligned DMA cost may
>  * outweigh the unaligned CPU cost.
>  */
> #ifndef NET_IP_ALIGN
> #define NET_IP_ALIGN 2
> #endif
> 
> Instead of skb_align make more sense? It does have the advantage of
> removing another magic number.

Yes.  Please add a paragraph to that comment explaining what "unaligned
CPU cost" really means, ie. that the IP/TCP header members are going to
be accessed with alignment less than the types might require on a given
architecture.

Then I'll apply this and we can start beating up the drivers.
