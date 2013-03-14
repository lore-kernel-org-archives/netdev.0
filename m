From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: LRO/GRO and libpcap packet reordering
Date: Fri, 15 Mar 2013 00:16:20 +0100
Message-ID: <1363302980.29475.45.camel@edumazet-glaptop>
References: <CALCETrXT036Aoaum+uUV_Of0AFdUZ3eq0QjMjxiCJR4n8AZRTQ@mail.gmail.com>
	 <1363298294.2695.15.camel@bwh-desktop.uk.solarflarecom.com>
	 <CALCETrUidEuaxBeDdDwGb=Dx5iGm1CK-HGWNXRUev5xoR9fnRg@mail.gmail.com>
	 <1363301695.29475.38.camel@edumazet-glaptop>
	 <CALCETrUpVKLr0i_3MZS_=dbxMGFzPYkpQh8qrzYqHFbjVqaKAg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Network Development <netdev@vger.kernel.org>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f41.google.com ([74.125.83.41]:45476 "EHLO
	mail-ee0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753285Ab3CNXQY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Mar 2013 19:16:24 -0400
Received: by mail-ee0-f41.google.com with SMTP id c13so1361011eek.28
        for <netdev@vger.kernel.org>; Thu, 14 Mar 2013 16:16:23 -0700 (PDT)
In-Reply-To: <CALCETrUpVKLr0i_3MZS_=dbxMGFzPYkpQh8qrzYqHFbjVqaKAg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-03-14 at 15:58 -0700, Andy Lutomirski wrote:

> Right.  This is the part that I'm wondering about an efficient fix to
> (i.e. flush GRO state for one flow whenever a packet for the reversed
> flow is seen).

It doesnt seem doable easily, because network header and tcp headers are
handled in two separate functions in GRO stack (inet_gro_receive() &
tcp_gro_receive()

What you could do is changing MAX_GRO_SKBS from 8 to 1
(basically allowing only one flow in GRO stack)
