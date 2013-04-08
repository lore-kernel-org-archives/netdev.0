From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: Re: [PATCH] netfilter: don't reset nf_trace in nf_reset()
Date: Mon, 08 Apr 2013 09:11:02 +0800
Message-ID: <51621926.10201@cn.fujitsu.com>
References: <1365187325-25147-1-git-send-email-kaber@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: pablo@netfilter.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:59163 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S934511Ab3DHBKM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 7 Apr 2013 21:10:12 -0400
In-Reply-To: <1365187325-25147-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/04/06 02:42, Patrick McHardy wrote:
> Commit 130549fe added code to reset nf_trace in nf_reset(). This is wrong
> and unnecessary.
> 
> nf_reset() is used in the following cases:
> 
> - when passing packets up the the socket layer, at which point we want to
>   release all netfilter references that might keep modules pinned while
>   the packet is queued. nf_trace doesn't matter anymore at this point.
> 
> - when encapsulating or decapsulating IPsec packets. We want to continue
>   tracing these packets after IPsec processing.
> 
> - when passing packets through virtual network devices. Only devices on
>   that encapsulate in IPv4/v6 matter since otherwise nf_trace is not
>   used anymore. Its not entirely clear whether those packets should
>   be traced after that, however we've always done that.
> 
> - when passing packets through virtual network devices that make the
>   packet cross network namespace boundaries. This is the only cases
>   where we clearly want to reset nf_trace and is also what the
>   original patch intended to fix.
> 
> Add a new function nf_reset_trace() and use it in dev_forward_skb() to
> fix this properly.
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>

Ok, I was confused by the nf_*reset*...
This patch is more proper,Since my commit will change the behavior of TRACE in some case.

Thanks for your fix and explanation.
