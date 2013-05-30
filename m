From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH 3/4 net-next] tcp: fix undo on partial ack in recovery
Date: Wed, 29 May 2013 20:49:31 -0400
Message-ID: <CADVnQymm0jVboO5bfkAi8OB-3oz8JPm9TX6+POcLdE=XQ4HFgg@mail.gmail.com>
References: <1369873214-29502-1-git-send-email-ycheng@google.com>
	<1369873214-29502-3-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Nandita Dukkipati <nanditad@google.com>,
	Andreas Terzis <aterzis@google.com>,
	Netdev <netdev@vger.kernel.org>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f180.google.com ([209.85.214.180]:35083 "EHLO
	mail-ob0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752593Ab3E3Atb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 May 2013 20:49:31 -0400
Received: by mail-ob0-f180.google.com with SMTP id eh20so3537399obb.39
        for <netdev@vger.kernel.org>; Wed, 29 May 2013 17:49:31 -0700 (PDT)
In-Reply-To: <1369873214-29502-3-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 29, 2013 at 8:20 PM, Yuchung Cheng <ycheng@google.com> wrote:
> Upon detecting spurious fast retransmit via timestamps during recovery,
> use PRR to clock out new data packet instead of retransmission. Once
> all retransmission are proven spurious, the sender then reverts the
> cwnd reduction and congestion state to open or disorder.
>
> The current code does the opposite: it undoes cwnd as soon as any
> retransmission is spurious and continues to retransmit until all
> data are acked. This nullifies the point to undo the cwnd because
> the sender is still retransmistting spuriously. This patch fixes
> it. The undo_ssthresh argument of tcp_undo_cwnd_reductiuon() is no
> longer needed and is removed.
>
> Signed-off-by: Yuchung Cheng <ycheng@google.com>

Acked-by: Neal Cardwell <ncardwell@google.com>
