From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH 1/4 net-next] tcp: consolidate SYNACK RTT sampling
Date: Sun, 21 Jul 2013 22:45:13 -0400
Message-ID: <CADVnQynNtha0Vc=oG=qiH94tAmWuQHjMcU-DFNudQdV_53+jeA@mail.gmail.com>
References: <1374385170-358-1-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Nandita Dukkipati <nanditad@google.com>,
	Netdev <netdev@vger.kernel.org>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f54.google.com ([74.125.83.54]:44207 "EHLO
	mail-ee0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754160Ab3GVCpP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Jul 2013 22:45:15 -0400
Received: by mail-ee0-f54.google.com with SMTP id t10so3509251eei.41
        for <netdev@vger.kernel.org>; Sun, 21 Jul 2013 19:45:13 -0700 (PDT)
In-Reply-To: <1374385170-358-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jul 21, 2013 at 1:39 AM, Yuchung Cheng <ycheng@google.com> wrote:
> This patch series improve RTT sampling in three ways:
> 1. Sample RTT during fast recovery and reordering events.
> 2. Favor ack-based RTT to timestamps because of broken TS ECR fields
> 3. Consolidate the RTT measurement logic.
>
> The first patch consolidates SYNACK and other RTT measurement to use a
> central function tcp_ack_update_rtt(). A (small) bonus is now SYNACK
> RTT measurement happens after PAWS check, potentially reducing the
> impact of RTO seeding on bad TCP timestamps values.
>
> Signed-off-by: Yuchung Cheng <ycheng@google.com>

The idea seems very nice to me, but I think a line or two got dropped
in a rebase. :-)

In the previous version of this patch you moved the TFO-specific call
to tcp_synack_rtt_meas() out to a spot in tcp_rcv_state_process()
where both TFO and non-TFO passive connections would hit it. In this
version of the patch it removes the existing calls to
tcp_synack_rtt_meas() but does not add this new call to replace them.
(And it does not seem to be added back in a later patch in the
series.)

Other than that, looks great.

neal
