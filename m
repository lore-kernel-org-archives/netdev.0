From: Nandita Dukkipati <nanditad@google.com>
Subject: Re: [PATCH] tcp: fix tcp_trim_head() to adjust segment count with skb MSS
Date: Sun, 29 Jan 2012 22:49:40 -0800
Message-ID: <CAB_+Fg43M7-5=x60KbCK7kOkr5x-EZpuWkN8Zx8jedHHWWE19A@mail.gmail.com>
References: <1327807786-27185-1-git-send-email-ncardwell@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	ilpo.jarvinen@helsinki.fi, Yuchung Cheng <ycheng@google.com>,
	Tom Herbert <therbert@google.com>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-tul01m020-f174.google.com ([209.85.214.174]:36543 "EHLO
	mail-tul01m020-f174.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750782Ab2A3Gtl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2012 01:49:41 -0500
Received: by obcva7 with SMTP id va7so3563886obc.19
        for <netdev@vger.kernel.org>; Sun, 29 Jan 2012 22:49:40 -0800 (PST)
In-Reply-To: <1327807786-27185-1-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 28, 2012 at 7:29 PM, Neal Cardwell <ncardwell@google.com> wrote:
>
> This commit fixes tcp_trim_head() to recalculate the number of
> segments in the skb with the skb's existing MSS, so trimming the head
> causes the skb segment count to be monotonically non-increasing - it
> should stay the same or go down, but not increase.
>
> Previously tcp_trim_head() used the current MSS of the connection. But
> if there was a decrease in MSS between original transmission and ACK
> (e.g. due to PMTUD), this could cause tcp_trim_head() to
> counter-intuitively increase the segment count when trimming bytes off
> the head of an skb. This violated assumptions in tcp_tso_acked() that
> tcp_trim_head() only decreases the packet count, so that packets_acked
> in tcp_tso_acked() could underflow, leading tcp_clean_rtx_queue() to
> pass u32 pkts_acked values as large as 0xffffffff to
> ca_ops->pkts_acked().
>
> As an aside, if tcp_trim_head() had really wanted the skb to reflect
> the current MSS, it should have called tcp_set_skb_tso_segs()
> unconditionally, since a decrease in MSS would mean that a
> single-packet skb should now be sliced into multiple segments.
>
> Signed-off-by: Neal Cardwell <ncardwell@google.com>

Acked-by: Nandita Dukkipati <nanditad@google.com>
