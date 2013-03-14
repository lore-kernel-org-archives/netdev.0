From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: LRO/GRO and libpcap packet reordering
Date: Thu, 14 Mar 2013 23:54:55 +0100
Message-ID: <1363301695.29475.38.camel@edumazet-glaptop>
References: <CALCETrXT036Aoaum+uUV_Of0AFdUZ3eq0QjMjxiCJR4n8AZRTQ@mail.gmail.com>
	 <1363298294.2695.15.camel@bwh-desktop.uk.solarflarecom.com>
	 <CALCETrUidEuaxBeDdDwGb=Dx5iGm1CK-HGWNXRUev5xoR9fnRg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Network Development <netdev@vger.kernel.org>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f171.google.com ([209.85.215.171]:49139 "EHLO
	mail-ea0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753093Ab3CNWy7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Mar 2013 18:54:59 -0400
Received: by mail-ea0-f171.google.com with SMTP id b15so1239649eae.30
        for <netdev@vger.kernel.org>; Thu, 14 Mar 2013 15:54:57 -0700 (PDT)
In-Reply-To: <CALCETrUidEuaxBeDdDwGb=Dx5iGm1CK-HGWNXRUev5xoR9fnRg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-03-14 at 15:45 -0700, Andy Lutomirski wrote:

> Hmm.  What if the GRO flow hashing was something like hash(one
> endpoint) ^ hash(the other endpoint)?  (NB: I don't really know what
> I'm talking about.)

There is no hashing in GRO, but a full flow match.

What you describe has to do with multi queue capability of the NIC.

Each flow is handled by a separate RX queue, therefore by different
cpus. There is no guarantee packets are delivered 'in order' in this
case, GRO being off or on.

Of course, if GRO/LRO is on, there is an additional delay to permit
aggregation, so a big GRO/LRO packet might appear _after_ an ACK.
