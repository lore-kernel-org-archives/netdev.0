From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next] tcp: gso: fix truesize tracking
Date: Fri, 25 Oct 2013 18:46:26 -0700
Message-ID: <CAMEtUuyj_ax49nz+LtkO-0=8=BH4v3tY34X=gkgiUZ_EiZXb-Q@mail.gmail.com>
References: <CAMEtUuzswOVA6UkPRjS-O=gOe9BLLJ5qaAG_eAd_fTqDJo8ofA@mail.gmail.com>
	<1382674000.7572.75.camel@edumazet-glaptop.roam.corp.google.com>
	<1382692140.7572.79.camel@edumazet-glaptop.roam.corp.google.com>
	<20131025.181809.348808013109842304.davem@davemloft.net>
	<CAMEtUuxwi05oX0TqNdMbjy04MT=ZLemLXJQTTcAMrnWuhXLKdQ@mail.gmail.com>
	<1382743502.4032.6.camel@edumazet-glaptop.roam.corp.google.com>
	<1382747177.4032.21.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>, stephen@networkplumber.org,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:41866 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752416Ab3JZBq1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Oct 2013 21:46:27 -0400
Received: by mail-wg0-f44.google.com with SMTP id n12so4558414wgh.23
        for <netdev@vger.kernel.org>; Fri, 25 Oct 2013 18:46:26 -0700 (PDT)
In-Reply-To: <1382747177.4032.21.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 25, 2013 at 5:26 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> commit 6ff50cd55545 ("tcp: gso: do not generate out of order packets")
> had an heuristic that can trigger a warning in skb_try_coalesce(),
> because skb->truesize of the gso segments were exactly set to mss.
>
> This breaks the requirement that
>
> skb->truesize >= skb->len + truesizeof(struct sk_buff);
>
> It can trivially be reproduced by :
>
> ifconfig lo mtu 1500
> ethtool -K lo tso off
> netperf
>
> As the skbs are looped into the TCP networking stack, skb_try_coalesce()
> warns us of these skb under-estimating their truesize.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Alexei Starovoitov <ast@plumgrid.com>
> ---

it fixed it in my setup. Thanks!
