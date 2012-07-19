From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3 6/7] net-tcp: Fast Open client - detecting SYN-data
 drops
Date: Thu, 19 Jul 2012 20:00:33 +0200
Message-ID: <1342720833.2626.4658.camel@edumazet-glaptop>
References: <1342716191-19196-1-git-send-email-ycheng@google.com>
	 <1342716191-19196-7-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, hkchu@google.com, edumazet@google.com,
	ncardwell@google.com, sivasankar@cs.ucsd.edu,
	netdev@vger.kernel.org
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f46.google.com ([209.85.212.46]:62644 "EHLO
	mail-vb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751380Ab2GSSAj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2012 14:00:39 -0400
Received: by vbbff1 with SMTP id ff1so2193055vbb.19
        for <netdev@vger.kernel.org>; Thu, 19 Jul 2012 11:00:39 -0700 (PDT)
In-Reply-To: <1342716191-19196-7-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-07-19 at 09:43 -0700, Yuchung Cheng wrote:
> On paths with firewalls dropping SYN with data or experimental TCP options,
> Fast Open connections will have experience SYN timeout and bad performance.
> The solution is to track such incidents in the cookie cache and disables
> Fast Open temporarily.
> 
> Since only the original SYN includes data and/or Fast Open option, the
> SYN-ACK has some tell-tale sign (tcp_rcv_fastopen_synack()) to detect
> such drops. If a path has recurring Fast Open SYN drops, Fast Open is
> disabled for 2^(recurring_losses) minutes starting from four minutes up to
> roughly one and half day. sendmsg with MSG_FASTOPEN flag will succeed but
> it behaves as connect() then write().
> 
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>
