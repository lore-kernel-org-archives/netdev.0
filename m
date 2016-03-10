From: Eric Dumazet <edumazet@google.com>
Subject: Re: [PATCH net-next v4] tcp: Add RFC4898 tcpEStatsPerfDataSegsOut/In
Date: Thu, 10 Mar 2016 09:39:20 -0800
Message-ID: <CANn89iJF2mw-2qFJ1r2xLo0FuH9JCNVPgTOAfnxL7nOX4qg2tg@mail.gmail.com>
References: <1457630961-2809690-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, Kernel Team <kernel-team@fb.com>,
	Chris Rapier <rapier@psc.edu>,
	Marcelo Ricardo Leitner <mleitner@redhat.com>,
	Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: Martin KaFai Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f179.google.com ([209.85.161.179]:36028 "EHLO
	mail-yw0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752773AbcCJRjV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Mar 2016 12:39:21 -0500
Received: by mail-yw0-f179.google.com with SMTP id g3so73623287ywa.3
        for <netdev@vger.kernel.org>; Thu, 10 Mar 2016 09:39:20 -0800 (PST)
In-Reply-To: <1457630961-2809690-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 10, 2016 at 9:29 AM, Martin KaFai Lau <kafai@fb.com> wrote:
> Per RFC4898, they count segments sent/received
> containing a positive length data segment (that includes
> retransmission segments carrying data).  Unlike
> tcpi_segs_out/in, tcpi_data_segs_out/in excludes segments
> carrying no data (e.g. pure ack).
>
> The patch also updates the segs_in in tcp_fastopen_add_skb()
> so that segs_in >= data_segs_in property is kept.  If
> tcp_segs_in() helper is used in this fastopen case, tp->segs_in
> has to be 0 reset first to avoid double counting.  Also, it has
> to be done before __skb_pull(skb, tcp_hdrlen(skb)) while
> there is no need to check skb->len since skb has already
> been confirmed carrying data.  I found it more confusing
> and chose to directly set segs_in and data_segs_in in
> this special case.

Note that on my TODO list after commit e11ecddf5128011c936cc5360780190cbc901fdc
I had the project of pulling TCP headers much earlier in input path
so that we do not have all these special cases.

Acked-by: Eric Dumazet <edumazet@google.com>
