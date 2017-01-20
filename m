From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Setting skb->csum in shared skb with csum-complete
Date: Thu, 19 Jan 2017 18:00:34 -0800
Message-ID: <1484877634.16328.71.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CALx6S34ZfFzPOmzfLoverXQ215AvasYejyJUv8wtWAVRumi-eg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:34732 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753992AbdATCAh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Jan 2017 21:00:37 -0500
Received: by mail-pf0-f196.google.com with SMTP id y143so4372962pfb.1
        for <netdev@vger.kernel.org>; Thu, 19 Jan 2017 18:00:37 -0800 (PST)
In-Reply-To: <CALx6S34ZfFzPOmzfLoverXQ215AvasYejyJUv8wtWAVRumi-eg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-01-19 at 17:29 -0800, Tom Herbert wrote:
> Hi Herbert,
> 
> I am looking at "net: Fix skb csum races when peeking". The context is
> that I'm seeing checksum faults after backporting mlx5 from driver.
> The handling of the checksum faults in interesting in itself. One side
> effect is that we end up recalculating and doing the dump twice when
> GRO is enabled. Another is that we validate checksum complete in a
> shared skbuf with a knowingly bad skb->csum value.
> 
> In the checksum fault case we recalculate the checksum and find it was
> actually correct in the packet. If the skb is not shared then we set
> the skb->csum to the correct value and also set skb->csum_complete_sw
> and skb->csum_valid. But if skb is shared we don't do any of that.
> This is kind of odd since __skb_checksum_complete_head then returns
> zero for an skb with checksum_complete where the checksum complete
> value is not correct. I'm not sure what the consequences of doing that
> are (I don't think it's related to issues I'm seeing) but this doesn't
> seem like a good thing. Maybe we should set skb->csum in this case
> since we know it's already wrong and the fact that skbuf is shared
> can't make it more wrong...

Why GRO can not change skb fields ?

skb can not be shared at GRO layer, so really this should be done there
if you want to avoid a double checksumming later.

You added all these skb fields, you know better than us ;)
