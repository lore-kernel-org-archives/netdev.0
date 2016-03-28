From: Jan Engelhardt <jengelh@inai.de>
Subject: Re: BUG: net/netfilter: KASAN: stack-out-of-bounds in tcp_packet
Date: Mon, 28 Mar 2016 22:20:39 +0200 (CEST)
Message-ID: <alpine.LSU.2.20.1603282214130.16241@nerf40.vanv.qr>
References: <56F8987B.5030501@gmail.com> <56F92E21.30509@gmail.com> <alpine.DEB.2.10.1603281844200.23985@blackhole.kfki.hu> <20160328.152959.1109841569654352040.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: kadlec@blackhole.kfki.hu, sploving1@gmail.com, pablo@netfilter.org,
	kaber@trash.net, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20160328.152959.1109841569654352040.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Monday 2016-03-28 21:29, David Miller wrote:
>>> > > @@ -3716,6 +3716,8 @@ void tcp_parse_options(const struct sk_buff *skb,
>>> > >               length--;
>>> > >               continue;
>>> > >           default:
>>> > > +            if (length < 2)
>>> > > +                return;
>>> > >               opsize = *ptr++;
>>> > >               if (opsize < 2) /* "silly options" */
>>> > >                   return;
>
>I'm trying to figure out how this can even matter.
>If we are in the loop, length is at least one.
>That means it is legal to read the opsize byte.

Is that because the skbuff is always padded to a multiple of (at
least) two? Maybe such padding is explicitly foregone when ASAN is in
place. After all, glibc, in userspace, is likely to do padding as
well for malloc, and yet, ASAN catches these cases.
