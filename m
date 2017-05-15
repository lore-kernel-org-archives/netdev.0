From: Ihar Hrachyshka <ihrachys@redhat.com>
Subject: Re: [PATCH] neighbour: update neigh timestamps iff update is effective
Date: Mon, 15 May 2017 14:35:26 -0700
Message-ID: <CAKwN9=C-_F-8GQ7yMO6wVR1Ukw3gCBYOzxxDRRLU9b-u9P1v-Q@mail.gmail.com>
References: <20170510000605.6799-1-ihrachys@redhat.com> <alpine.LFD.2.20.1705152234490.4002@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "David S. Miller" <davem@davemloft.net>,
        He Chunhui <hchunhui@mail.ustc.edu.cn>, netdev@vger.kernel.org
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f170.google.com ([209.85.161.170]:36199 "EHLO
        mail-yw0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750877AbdEOVfr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 15 May 2017 17:35:47 -0400
Received: by mail-yw0-f170.google.com with SMTP id b68so44414181ywe.3
        for <netdev@vger.kernel.org>; Mon, 15 May 2017 14:35:47 -0700 (PDT)
In-Reply-To: <alpine.LFD.2.20.1705152234490.4002@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 15, 2017 at 1:05 PM, Julian Anastasov <ja@ssi.bg> wrote:
>
>         It seems arp_accept value currently has influence on
> the locktime for GARP requests. My understanding is that
> locktime is used to ignore replies from proxy_arp
> routers while the requested IP is present on the LAN
> and replies immediately. IMHO, GARP requests should not
> depend on locktime, even when arp_accept=0. For example:

Yes, I believe so.

I actually thought about introducing the patch that does just that:
forcing override on garp, but then I was thinking, maybe there is some
reason to still apply locktime rules to garps; f.e. if you have
multiple nodes carrying the ip address and located on the same
segment, maybe you want to pick the first that replies to you (in
theory, it may be the node that is less loaded, or closer to us; but
then, it's so fragile even if that was the intent...) Do you want me
to post the patch, or will you cover it?

Ihar
