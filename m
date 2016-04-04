From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [RFC PATCH net 3/4] ipv6: datagram: Update dst cache of a
 connected datagram sk during pmtu update
Date: Mon, 4 Apr 2016 13:45:02 -0700
Message-ID: <CAM_iQpXV8UrBycmmTn3-FFEoR69OSvc4cWZMGbPnGiHF5aF7Dg@mail.gmail.com>
References: <1459551391-69969-1-git-send-email-kafai@fb.com>
	<1459551391-69969-4-git-send-email-kafai@fb.com>
	<CAM_iQpVeOKtTJ=oc9z6=SEaHDBTfpaPLKa-43TH1b_A3+TdWwA@mail.gmail.com>
	<20160403023349.GA57008@lichen-mbp.local.DHCP.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Wei Wang <weiwan@google.com>, Kernel Team <kernel-team@fb.com>
To: Martin KaFai Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f171.google.com ([209.85.161.171]:35751 "EHLO
	mail-yw0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932459AbcDDUpD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Apr 2016 16:45:03 -0400
Received: by mail-yw0-f171.google.com with SMTP id g127so267160556ywf.2
        for <netdev@vger.kernel.org>; Mon, 04 Apr 2016 13:45:03 -0700 (PDT)
In-Reply-To: <20160403023349.GA57008@lichen-mbp.local.DHCP.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Apr 2, 2016 at 7:33 PM, Martin KaFai Lau <kafai@fb.com> wrote:
> One thing to note is that this patch uses the addresses from the sk
> instead of iph when updating sk->sk_dst_cache.  It is basically the
> same logic that the __ip6_datagram_connect() is doing, so some
> refactoring works in the first two patches.
>
> AFAIK, a UDP socket can become connected after sending out some
> datagrams in un-connected state.  or It can be connected
> multiple times to different destinations.  I did some quick
> tests but I could be wrong.
>
> I am thinking if there could be a chance that the skb->data, which
> has the original outgoing iph, is not related to the current
> connected address.  If it is possible, we have to specifically
> use the addresses in the sk instead of skb->data (i.e. iph) when
> updating the sk->sk_dst_cache.
>
> If we need to use the sk addresses (and other info) to find out a
> new dst for a connected udp socket, it is better not doing it while
> the userland is connecting to somewhere else.
>
> If the above case is impossible, we can keep using the info from iph to
> do the dst update for a connected-udp sk without taking the lock.

I see your point, but calling __ip6_datagram_connect() seems overkill
here, we don't need to update so many things in the pmtu update context,
at least IPv4 doesn't do that either. I don't think you have to do that.

So why just updating the dst cache (also some addr cache) here is not
enough?
