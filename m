From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: copy_skb_header() and sk_buff flags (question)
Date: Wed, 22 Aug 2012 07:21:19 +0200
Message-ID: <1345612879.5158.569.camel@edumazet-glaptop>
References: <CAGXs5wVp2bLnwFiuYEg6ZOv0t3DX4PCCgY-EURbs5bySgEqtdw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Kevin Wilson <wkevils@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:49099 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753453Ab2HVFVZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2012 01:21:25 -0400
Received: by weyx8 with SMTP id x8so346295wey.19
        for <netdev@vger.kernel.org>; Tue, 21 Aug 2012 22:21:23 -0700 (PDT)
In-Reply-To: <CAGXs5wVp2bLnwFiuYEg6ZOv0t3DX4PCCgY-EURbs5bySgEqtdw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-08-22 at 07:55 +0300, Kevin Wilson wrote:
> Hello,
> 
> I have a question if I may, as I cannot understand this point:
> 
> I try to understand why in __copy_skb_header() we copy various flags
> (like ip_summed,
> local_df, pkt_type, priority, ipvs_property, and more. But there are
> flags which we do
> not copy, like nohdr, or fclone, or peeked.
> 
>  Aren't these flags part of the sk_buff header?

Caller should take care of said bits.

peeked is probably always 0 at this point...

I tried to use a single memcpy() to speedup things, but found out
it was not a trivial thing...
