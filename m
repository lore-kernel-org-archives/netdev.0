From: David Miller <davem@davemloft.net>
Subject: Re: BUG: net/netfilter: KASAN: stack-out-of-bounds in tcp_packet
Date: Mon, 28 Mar 2016 19:52:33 -0400 (EDT)
Message-ID: <20160328.195233.2182703562129135393.davem@davemloft.net>
References: <alpine.DEB.2.10.1603281844200.23985@blackhole.kfki.hu>
	<20160328.152959.1109841569654352040.davem@davemloft.net>
	<alpine.LSU.2.20.1603282214130.16241@nerf40.vanv.qr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kadlec@blackhole.kfki.hu, sploving1@gmail.com, pablo@netfilter.org,
	kaber@trash.net, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: jengelh@inai.de
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LSU.2.20.1603282214130.16241@nerf40.vanv.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jan Engelhardt <jengelh@inai.de>
Date: Mon, 28 Mar 2016 22:20:39 +0200 (CEST)

> 
> On Monday 2016-03-28 21:29, David Miller wrote:
>>>> > > @@ -3716,6 +3716,8 @@ void tcp_parse_options(const struct sk_buff *skb,
>>>> > >               length--;
>>>> > >               continue;
>>>> > >           default:
>>>> > > +            if (length < 2)
>>>> > > +                return;
>>>> > >               opsize = *ptr++;
>>>> > >               if (opsize < 2) /* "silly options" */
>>>> > >                   return;
>>
>>I'm trying to figure out how this can even matter.
>>If we are in the loop, length is at least one.
>>That means it is legal to read the opsize byte.
> 
> Is that because the skbuff is always padded to a multiple of (at
> least) two?

No, it's because length is at least one, so we can read one byte.

And then before we read more, we make sure length is at least opsize
which is at least two.

This has nothing to do with padding, and everything to do logically
with the code.
