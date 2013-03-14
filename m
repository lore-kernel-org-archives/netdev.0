From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: LRO/GRO and libpcap packet reordering
Date: Thu, 14 Mar 2013 15:58:12 -0700
Message-ID: <CALCETrUpVKLr0i_3MZS_=dbxMGFzPYkpQh8qrzYqHFbjVqaKAg@mail.gmail.com>
References: <CALCETrXT036Aoaum+uUV_Of0AFdUZ3eq0QjMjxiCJR4n8AZRTQ@mail.gmail.com>
 <1363298294.2695.15.camel@bwh-desktop.uk.solarflarecom.com>
 <CALCETrUidEuaxBeDdDwGb=Dx5iGm1CK-HGWNXRUev5xoR9fnRg@mail.gmail.com> <1363301695.29475.38.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Network Development <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f51.google.com ([209.85.212.51]:53598 "EHLO
	mail-vb0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753175Ab3CNW6f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Mar 2013 18:58:35 -0400
Received: by mail-vb0-f51.google.com with SMTP id fq11so1489297vbb.24
        for <netdev@vger.kernel.org>; Thu, 14 Mar 2013 15:58:32 -0700 (PDT)
In-Reply-To: <1363301695.29475.38.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 14, 2013 at 3:54 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2013-03-14 at 15:45 -0700, Andy Lutomirski wrote:
>
>> Hmm.  What if the GRO flow hashing was something like hash(one
>> endpoint) ^ hash(the other endpoint)?  (NB: I don't really know what
>> I'm talking about.)
>
> There is no hashing in GRO, but a full flow match.
>
> What you describe has to do with multi queue capability of the NIC.
>
> Each flow is handled by a separate RX queue, therefore by different
> cpus. There is no guarantee packets are delivered 'in order' in this
> case, GRO being off or on.

This happens even when there's just one rx queue.  (I checked that
before scratching my head for a while.)

>
> Of course, if GRO/LRO is on, there is an additional delay to permit
> aggregation, so a big GRO/LRO packet might appear _after_ an ACK.
>
>

Right.  This is the part that I'm wondering about an efficient fix to
(i.e. flush GRO state for one flow whenever a packet for the reversed
flow is seen).


--Andy
