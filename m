From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH] tcp: remove useless update for flag parameter in tcp_enter_frto_loss()
Date: Wed, 28 Mar 2012 01:29:02 -0400
Message-ID: <CADVnQymQaCSKx0aRda6OiP=t2OToxHmvjXjYvTdxsq7oFE3DTg@mail.gmail.com>
References: <4F729235.8040706@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Li Yu <raise.sail@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f174.google.com ([209.85.216.174]:33261 "EHLO
	mail-qc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750941Ab2C1FfT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Mar 2012 01:35:19 -0400
Received: by qcqw6 with SMTP id w6so464049qcq.19
        for <netdev@vger.kernel.org>; Tue, 27 Mar 2012 22:35:18 -0700 (PDT)
In-Reply-To: <4F729235.8040706@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 28, 2012 at 12:23 AM, Li Yu <raise.sail@gmail.com> wrote:
>
> It seem that we forget remove below two lines after copying code :)
>
> This update never impacts others.

The 'flag' variable will be used in later iterations of the
tcp_for_write_queue() loop. The comment seems to quite sensibly
indicate that the FLAG_DATA_ACKED bit is being set to avoid entering
that branch of the if statement in later segments in the loop:

2168                 if ((tp->frto_counter == 1) && !(flag & FLAG_DATA_ACKED)) {
2169                         /* For some reason this R-bit might get cleared? */
2170                         if (TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_RETRANS)
2171                                 tp->retrans_out += tcp_skb_pcount(skb);
2172                         /* ...enter this if branch just for the
first segment */
2173                         flag |= FLAG_DATA_ACKED;
2174                 } else {

The structure of the logic seems intact from the original commit that
added this:

http://git.kernel.org/?p=linux/kernel/git/torvalds/linux.git;a=commitdiff;h=d1a54c6a0a3f9c2c4ef71982d89b8571bd9eaa51

neal
