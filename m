From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v2 1/2] pkt_sched: fq: avoid artificial bursts
 for clocked flows
Date: Tue, 03 Feb 2015 14:06:04 -0800
Message-ID: <1423001164.907.43.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1422992932-9893-1-git-send-email-kennetkl@ifi.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Kenneth Klette Jonassen <kennetkl@ifi.uio.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f173.google.com ([209.85.213.173]:39503 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752465AbbBCWGG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Feb 2015 17:06:06 -0500
Received: by mail-ig0-f173.google.com with SMTP id a13so30261125igq.0
        for <netdev@vger.kernel.org>; Tue, 03 Feb 2015 14:06:06 -0800 (PST)
In-Reply-To: <1422992932-9893-1-git-send-email-kennetkl@ifi.uio.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-02-03 at 20:48 +0100, Kenneth Klette Jonassen wrote:
>  
> -	if (tb[TCA_FQ_INITIAL_QUANTUM])
> -		q->initial_quantum = nla_get_u32(tb[TCA_FQ_INITIAL_QUANTUM]);
> +	if (tb[TCA_FQ_INITIAL_QUANTUM]) {
> +		u32 initial_quantum = nla_get_u32(tb[TCA_FQ_INITIAL_QUANTUM]);
> +
> +		if (initial_quantum > q->quantum)
> +			q->initial_quantum = initial_quantum - q->quantum;
> +		else
> +			q->initial_quantum = 0;
> +	}

Please do not mix patches. This part already have been Acked by me.

Quite frankly I do not like this patch.

There is no rush, and you touch some critical infrastructure for us.

Always CC me on any fq change, do not assume I catch all netdev
messages.
