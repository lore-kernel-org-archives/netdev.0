From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: LRO/GRO and libpcap packet reordering
Date: Fri, 15 Mar 2013 00:21:29 +0100
Message-ID: <1363303289.29475.47.camel@edumazet-glaptop>
References: <CALCETrXT036Aoaum+uUV_Of0AFdUZ3eq0QjMjxiCJR4n8AZRTQ@mail.gmail.com>
	 <1363298294.2695.15.camel@bwh-desktop.uk.solarflarecom.com>
	 <CALCETrUidEuaxBeDdDwGb=Dx5iGm1CK-HGWNXRUev5xoR9fnRg@mail.gmail.com>
	 <1363301695.29475.38.camel@edumazet-glaptop>
	 <CALCETrUpVKLr0i_3MZS_=dbxMGFzPYkpQh8qrzYqHFbjVqaKAg@mail.gmail.com>
	 <1363302980.29475.45.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Network Development <netdev@vger.kernel.org>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f174.google.com ([209.85.215.174]:42021 "EHLO
	mail-ea0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753106Ab3CNXVe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Mar 2013 19:21:34 -0400
Received: by mail-ea0-f174.google.com with SMTP id q10so1299309eaj.33
        for <netdev@vger.kernel.org>; Thu, 14 Mar 2013 16:21:32 -0700 (PDT)
In-Reply-To: <1363302980.29475.45.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-03-15 at 00:16 +0100, Eric Dumazet wrote:
> On Thu, 2013-03-14 at 15:58 -0700, Andy Lutomirski wrote:
> 
> > Right.  This is the part that I'm wondering about an efficient fix to
> > (i.e. flush GRO state for one flow whenever a packet for the reversed
> > flow is seen).
> 
> It doesnt seem doable easily, because network header and tcp headers are
> handled in two separate functions in GRO stack (inet_gro_receive() &
> tcp_gro_receive()
> 
> What you could do is changing MAX_GRO_SKBS from 8 to 1
> (basically allowing only one flow in GRO stack)
> 
> 
Well, its not enough, some changes would be needed to force a flush each
time a new flow is detected.
