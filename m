From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] tcp: fix RTO calculated from cached RTT
Date: Tue, 17 Sep 2013 05:21:02 -0700
Message-ID: <1379420462.3457.11.camel@edumazet-glaptop>
References: <1379382260-29303-1-git-send-email-ncardwell@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Eric Dumazet <edumazet@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:46079 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752611Ab3IQMVF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Sep 2013 08:21:05 -0400
Received: by mail-pd0-f179.google.com with SMTP id v10so5479470pde.24
        for <netdev@vger.kernel.org>; Tue, 17 Sep 2013 05:21:04 -0700 (PDT)
In-Reply-To: <1379382260-29303-1-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-09-16 at 21:44 -0400, Neal Cardwell wrote:
> Commit 1b7fdd2ab5852 ("tcp: do not use cached RTT for RTT estimation")
> did not correctly account for the fact that crtt is the RTT shifted
> left 3 bits. Fix the calculation to consistently reflect this fact.
> 
> Signed-off-by: Neal Cardwell <ncardwell@google.com>
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: Yuchung Cheng <ycheng@google.com>
> ---
>  net/ipv4/tcp_metrics.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)

Acked-by: Eric Dumazet <edumazet@google.com>

Instead of rto = 3*crtt, we had rto = 10*crtt, which was indeed
suboptimal ;)
