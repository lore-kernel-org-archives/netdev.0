From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH next] Revert "dctcp: update cwnd on congestion event"
Date: Tue, 06 Dec 2016 11:34:42 -0500 (EST)
Message-ID: <20161206.113442.100496871002228037.davem@davemloft.net>
References: <1480980180-23349-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ncardwell@google.com
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42966 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751764AbcLFQfQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2016 11:35:16 -0500
In-Reply-To: <1480980180-23349-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Tue,  6 Dec 2016 00:23:00 +0100

> Neal Cardwell says:
>  If I am reading the code correctly, then I would have two concerns:
>  1) Has that been tested? That seems like an extremely dramatic
>     decrease in cwnd. For example, if the cwnd is 80, and there are 40
>     ACKs, and half the ACKs are ECE marked, then my back-of-the-envelope
>     calculations seem to suggest that after just 11 ACKs the cwnd would be
>     down to a minimal value of 2 [..]
>  2) That seems to contradict another passage in the draft [..] where it
>     sazs:
>        Just as specified in [RFC3168], DCTCP does not react to congestion
>        indications more than once for every window of data.
> 
> Neal is right.  Fortunately we don't have to complicate this by testing
> vs. current rtt estimate, we can just revert the patch.
> 
> Normal stack already handles this for us: receiving ACKs with ECE
> set causes a call to tcp_enter_cwr(), from there on the ssthresh gets
> adjusted and prr will take care of cwnd adjustment.
> 
> Fixes: 4780566784b396 ("dctcp: update cwnd on congestion event")
> Cc: Neal Cardwell <ncardwell@google.com>
> Signed-off-by: Florian Westphal <fw@strlen.de>

Applied.
