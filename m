From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next] tcp: remove cwnd moderation after recovery
Date: Tue, 29 Mar 2016 17:35:45 -0700
Message-ID: <20160329173545.5fe0ae8b@xeon-e3>
References: <1459296952-12214-1-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Matt Mathis <mattmathis@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Soheil Hassas Yeganeh <soheil@google.com>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:36279 "EHLO
	mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752265AbcC3Afb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Mar 2016 20:35:31 -0400
Received: by mail-pf0-f181.google.com with SMTP id e128so6390013pfe.3
        for <netdev@vger.kernel.org>; Tue, 29 Mar 2016 17:35:30 -0700 (PDT)
In-Reply-To: <1459296952-12214-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 29 Mar 2016 17:15:52 -0700
Yuchung Cheng <ycheng@google.com> wrote:

> For non-SACK connections, cwnd is lowered to inflight plus 3 packets
> when the recovery ends. This is an optional feature in the NewReno
> RFC 2582 to reduce the potential burst when cwnd is "re-opened"
> after recovery and inflight is low.
> 
> This feature is questionably effective because of PRR: when
> the recovery ends (i.e., snd_una == high_seq) NewReno holds the
> CA_Recovery state for another round trip to prevent false fast
> retransmits. But if the inflight is low, PRR will overwrite the
> moderated cwnd in tcp_cwnd_reduction() later.
> 
> On the other hand, if the recovery ends because the sender
> detects the losses were spurious (e.g., reordering). This feature
> unconditionally lowers a reverted cwnd even though nothing
> was lost.
> 
> By principle loss recovery module should not update cwnd. Further
> pacing is much more effective to reduce burst. Hence this patch
> removes the cwnd moderation feature.
> 
> Signed-off-by: Matt Mathis <mattmathis@google.com>
> Signed-off-by: Neal Cardwell <ncardwell@google.com>
> Signed-off-by: Soheil Hassas Yeganeh <soheil@google.com>

I have a concern that this might break Linux builtin protection
against hostile receiver sending bogus ACK's.  Remember Linux is
different than NewReno. You are changing something that has existed for
a long long time.
