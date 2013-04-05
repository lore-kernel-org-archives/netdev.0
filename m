From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] netfilter: don't reset nf_trace in nf_reset()
Date: Fri, 05 Apr 2013 23:14:30 +0400
Message-ID: <515F2296.6070001@cogentembedded.com>
References: <1365187325-25147-1-git-send-email-kaber@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: pablo@netfilter.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, gaofeng@cn.fujitsu.com
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f45.google.com ([209.85.215.45]:39146 "EHLO
	mail-la0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1162524Ab3DETPn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Apr 2013 15:15:43 -0400
Received: by mail-la0-f45.google.com with SMTP id fn20so320100lab.18
        for <netdev@vger.kernel.org>; Fri, 05 Apr 2013 12:15:42 -0700 (PDT)
In-Reply-To: <1365187325-25147-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/05/2013 10:42 PM, Patrick McHardy wrote:

> Commit 130549fe

    Please also specify the summary line of this commit in parens.
David M. also seems to require it to be enclosed in quotes inside parens...

> added code to reset nf_trace in nf_reset(). This is wrong
> and unnecessary.
>
> nf_reset() is used in the following cases:
>
> - when passing packets up the the socket layer, at which point we want to
>    release all netfilter references that might keep modules pinned while
>    the packet is queued. nf_trace doesn't matter anymore at this point.
>
> - when encapsulating or decapsulating IPsec packets. We want to continue
>    tracing these packets after IPsec processing.
>
> - when passing packets through virtual network devices. Only devices on
>    that encapsulate in IPv4/v6 matter since otherwise nf_trace is not
>    used anymore. Its not entirely clear whether those packets should
>    be traced after that, however we've always done that.
>
> - when passing packets through virtual network devices that make the
>    packet cross network namespace boundaries. This is the only cases
>    where we clearly want to reset nf_trace and is also what the
>    original patch intended to fix.
>
> Add a new function nf_reset_trace() and use it in dev_forward_skb() to
> fix this properly.
>
> Signed-off-by: Patrick McHardy <kaber@trash.net>
>

WBR, Sergei
