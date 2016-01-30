From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net PATCH] flow_dissector: Fix unaligned access in
 __skb_flow_dissector when used by eth_get_headlen
Date: Fri, 29 Jan 2016 19:23:54 -0800
Message-ID: <1454124234.7627.119.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20160129180651.GA17127@oracle.com>
	 <20160130024556.6227.51798.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	alexander.duyck@gmail.com,
	Sowmini Varadhan <sowmini.varadhan@oracle.com>,
	tom@herbertland.com
To: Alexander Duyck <aduyck@mirantis.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:35476 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751304AbcA3DX5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jan 2016 22:23:57 -0500
Received: by mail-pa0-f54.google.com with SMTP id ho8so50919608pac.2
        for <netdev@vger.kernel.org>; Fri, 29 Jan 2016 19:23:56 -0800 (PST)
In-Reply-To: <20160130024556.6227.51798.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-01-29 at 18:49 -0800, Alexander Duyck wrote:
> This patch fixes an issue with unaligned accesses when using
> eth_get_headlen on a page that was DMA aligned instead of being IP aligned.
> The fact is when trying to check the length we don't need to be looking at
> the flow label so we can reorder the checks to first check if we are
> supposed to gather the flow label and then make the call to actually get
> it.
> 
> Reported-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
> Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
> ---


You did not quite follow the discussion Alexander, we did not exactly
took a decision about this bug.

As we mentioned, there are other parts that need care.

key_keyid->keyid = *keyid;

Please address them, instead of having to 'wait' for the next crash.

BTW, even a memcpy(&key_addrs->v4addrs, &iph->saddr, 8) could crash, as
the compiler can certainly assume src and dst are 4 bytes aligned, and
could use word accesses when inlining memcpy() even on Sparc.

Apparently the compiler used by Sowmini is gentle.

Thanks.
