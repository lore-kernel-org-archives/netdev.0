From: Nandita Dukkipati <nanditad@google.com>
Subject: Re: [PATCH] tcp: don't fragment SACKed skbs in tcp_mark_head_lost()
Date: Sat, 3 Mar 2012 10:03:56 -0800
Message-ID: <CAB_+Fg6x=0jFVysUK8stU1YEL4NGqid7h_XKfRW7BVVeYp3bcg@mail.gmail.com>
References: <1330760211-25785-1-git-send-email-ncardwell@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	ilpo.jarvinen@helsinki.fi, Yuchung Cheng <ycheng@google.com>,
	Tom Herbert <therbert@google.com>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-tul01m020-f174.google.com ([209.85.214.174]:42773 "EHLO
	mail-tul01m020-f174.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751949Ab2CCSD5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Mar 2012 13:03:57 -0500
Received: by obbuo6 with SMTP id uo6so2763595obb.19
        for <netdev@vger.kernel.org>; Sat, 03 Mar 2012 10:03:56 -0800 (PST)
In-Reply-To: <1330760211-25785-1-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 2, 2012 at 11:36 PM, Neal Cardwell <ncardwell@google.com> wrote:
>
> In tcp_mark_head_lost() we should not attempt to fragment a SACKed skb
> to mark the first portion as lost. This is for two primary reasons:
>
> (1) tcp_shifted_skb() coalesces adjacent regions of SACKed skbs. When
> doing this, it preserves the sum of their packet counts in order to
> reflect the real-world dynamics on the wire. But given that skbs can
> have remainders that do not align to MSS boundaries, this packet count
> preservation means that for SACKed skbs there is not necessarily a
> direct linear relationship between tcp_skb_pcount(skb) and
> skb->len. Thus tcp_mark_head_lost()'s previous attempts to fragment
> off and mark as lost a prefix of length (packets - oldcnt)*mss from
> SACKed skbs were leading to occasional failures of the WARN_ON(len >
> skb->len) in tcp_fragment() (which used to be a BUG_ON(); see the
> recent "crash in tcp_fragment" thread on netdev).
>
> (2) there is no real point in fragmenting off part of a SACKed skb and
> calling tcp_skb_mark_lost() on it, since tcp_skb_mark_lost() is a NOP
> for SACKed skbs.
>
> Signed-off-by: Neal Cardwell <ncardwell@google.com>

Acked-by: Nandita Dukkipati <nanditad@google.com>
