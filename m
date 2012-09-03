From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH 3/3] tcp: use PRR to reduce cwin in CWR state
Date: Mon, 3 Sep 2012 00:00:44 -0400
Message-ID: <CADVnQyma09UtSLusyQ6986uz2yfy-3xZ+mXrHfn1A2HO+3=X_g@mail.gmail.com>
References: <1346643484-12947-1-git-send-email-ycheng@google.com>
	<1346643484-12947-3-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	Nandita Dukkipati <nanditad@google.com>,
	Matt Mathis <mattmathis@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Netdev <netdev@vger.kernel.org>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:56054 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750818Ab2ICEAo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Sep 2012 00:00:44 -0400
Received: by iahk25 with SMTP id k25so3716928iah.19
        for <netdev@vger.kernel.org>; Sun, 02 Sep 2012 21:00:44 -0700 (PDT)
In-Reply-To: <1346643484-12947-3-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Sep 2, 2012 at 11:38 PM, Yuchung Cheng <ycheng@google.com> wrote:
> Use proportional rate reduction (PRR) algorithm to reduce cwnd in CWR state,
> in addition to Recovery state. Retire the current rate-halving in CWR.
> When losses are detected via ACKs in CWR state, the sender enters Recovery
> state but the cwnd reduction continues and does not restart.
>
> Rename and refactor cwnd reduction functions since both CWR and Recovery
> use the same algorithm:
> tcp_init_cwnd_reduction() is new and initiates reduction state variables.
> tcp_cwnd_reduction() is previously tcp_update_cwnd_in_recovery().
> tcp_ends_cwnd_reduction() is previously  tcp_complete_cwr().
>
> The rate halving functions and logic such as tcp_cwnd_down(), tcp_min_cwnd(),
> and the cwnd moderation inside tcp_enter_cwr() are removed. The unused
> parameter, flag, in tcp_cwnd_reduction() is also removed.
>
> Signed-off-by: Yuchung Cheng <ycheng@google.com>

Acked-by: Neal Cardwell <ncardwell@google.com>

neal
