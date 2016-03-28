From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: BUG: net/netfilter: KASAN: stack-out-of-bounds in tcp_packet
Date: Mon, 28 Mar 2016 13:46:03 -0700
Message-ID: <1459197963.6473.125.camel@edumazet-glaptop3.roam.corp.google.com>
References: <56F8987B.5030501@gmail.com> <56F92E21.30509@gmail.com>
	 <alpine.DEB.2.10.1603281844200.23985@blackhole.kfki.hu>
	 <20160328.152959.1109841569654352040.davem@davemloft.net>
	 <alpine.LSU.2.20.1603282214130.16241@nerf40.vanv.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, kadlec@blackhole.kfki.hu,
	sploving1@gmail.com, pablo@netfilter.org, kaber@trash.net,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Jan Engelhardt <jengelh@inai.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:33868 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751281AbcC1UqH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Mar 2016 16:46:07 -0400
In-Reply-To: <alpine.LSU.2.20.1603282214130.16241@nerf40.vanv.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-03-28 at 22:20 +0200, Jan Engelhardt wrote:
> On Monday 2016-03-28 21:29, David Miller wrote:
> >>> > > @@ -3716,6 +3716,8 @@ void tcp_parse_options(const struct sk_buff *skb,
> >>> > >               length--;
> >>> > >               continue;
> >>> > >           default:
> >>> > > +            if (length < 2)
> >>> > > +                return;
> >>> > >               opsize = *ptr++;
> >>> > >               if (opsize < 2) /* "silly options" */
> >>> > >                   return;
> >
> >I'm trying to figure out how this can even matter.
> >If we are in the loop, length is at least one.
> >That means it is legal to read the opsize byte.
> 
> Is that because the skbuff is always padded to a multiple of (at
> least) two? Maybe such padding is explicitly foregone when ASAN is in
> place. After all, glibc, in userspace, is likely to do padding as
> well for malloc, and yet, ASAN catches these cases.

We have at least 384 bytes of padding in skb->head (this is struct
skb_shared_info).

Whatever garbage we might read, current code is fine.

We have to deal with a false positive here.
