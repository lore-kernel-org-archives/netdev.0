From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH v2 net-next] tcp: fix slow start after idle vs TSO/GSO
Date: Fri, 21 Aug 2015 21:43:22 -0400
Message-ID: <CADVnQynwaW0DEJE+kiLeaJ59rBaZ-uE2dWOyx+RH-LXxTBr_Ug@mail.gmail.com>
References: <1440090487.6610.59.camel@edumazet-glaptop2.roam.corp.google.com>
	<1440185400.6610.90.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f171.google.com ([209.85.214.171]:34601 "EHLO
	mail-ob0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752901AbbHVBnY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Aug 2015 21:43:24 -0400
Received: by obbfr1 with SMTP id fr1so72410022obb.1
        for <netdev@vger.kernel.org>; Fri, 21 Aug 2015 18:43:22 -0700 (PDT)
In-Reply-To: <1440185400.6610.90.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 21, 2015 at 3:30 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> slow start after idle might reduce cwnd, but we perform this
> after first packet was cooked and sent.
>
> With TSO/GSO, it means that we might send a full TSO packet
> even if cwnd should have been reduced to IW10.
>
> Moving the SSAI check in skb_entail() makes sense, because
> we slightly reduce number of times this check is done,
> especially for large send() and TCP Small queue callbacks from
> softirq context.
>
> As Neal pointed out, we also need to perform the check
> if/when receive window opens.
...
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Neal Cardwell <ncardwell@google.com>
> Cc: Yuchung Cheng <ycheng@google.com>
> ---

Acked-by: Neal Cardwell <ncardwell@google.com>

Looks good to me. Thanks, Eric!

neal
