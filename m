From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH next] Revert "dctcp: update cwnd on congestion event"
Date: Mon, 5 Dec 2016 21:11:50 -0500
Message-ID: <CADVnQynFS6g_Tr287p9U1u5p70HjOprkD0N9Ep_1p3v-Kb04zQ@mail.gmail.com>
References: <1480980180-23349-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f51.google.com ([209.85.218.51]:36056 "EHLO
        mail-oi0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752630AbcLFCMW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Dec 2016 21:12:22 -0500
Received: by mail-oi0-f51.google.com with SMTP id v84so362503538oie.3
        for <netdev@vger.kernel.org>; Mon, 05 Dec 2016 18:12:21 -0800 (PST)
In-Reply-To: <1480980180-23349-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 5, 2016 at 6:23 PM, Florian Westphal <fw@strlen.de> wrote:
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
> ---

Acked-by: Neal Cardwell <ncardwell@google.com>

Looks good to me. :-)

Thanks,
neal
