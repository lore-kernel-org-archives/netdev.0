From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net-next] tcp: reset reordering est. selectively on timeout
Date: Tue, 13 Aug 2013 00:16:57 -0400
Message-ID: <CADVnQykaYF5xQJbv-m6d3xKMHSYZQVjmua2CqXkGdwdo_iqSwA@mail.gmail.com>
References: <1376350885-32407-1-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Matt Mathis <mattmathis@google.com>,
	Netdev <netdev@vger.kernel.org>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f50.google.com ([74.125.83.50]:52482 "EHLO
	mail-ee0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751080Ab3HMEQ6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Aug 2013 00:16:58 -0400
Received: by mail-ee0-f50.google.com with SMTP id d51so3960088eek.9
        for <netdev@vger.kernel.org>; Mon, 12 Aug 2013 21:16:57 -0700 (PDT)
In-Reply-To: <1376350885-32407-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 12, 2013 at 7:41 PM, Yuchung Cheng <ycheng@google.com> wrote:
> On timeout the TCP sender unconditionally reset the estimated
> degree of network reordering (tp->reordering). This idea behind
> is that the estimate is too large to trigger fast recovery
> (e.g., due to a IP path change).
>
> But for example if the sender only had 2 packets outstanding,
> then a timeout doesn't tell much about reordering. A sender that
> learns about reordering on big writes and lose packets on small
> writes will end up falsely retransmit again and again, especially
> when reordering is more likely on big writes.
>
> Therefore the sender should only suspects tp->reordering is too
> high if it could have gone into fast recovery with the (lower)
> default estimate.
>
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> ---
>  net/ipv4/tcp_input.c | 9 +++++++--
>  1 file changed, 7 insertions(+), 2 deletions(-)

Acked-by: Neal Cardwell <ncardwell@google.com>

neal
