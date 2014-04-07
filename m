From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: filter: be more defensive on div/mod by X==0
Date: Mon, 07 Apr 2014 12:55:09 -0400 (EDT)
Message-ID: <20140407.125509.554303783565384171.davem@davemloft.net>
References: <1396652643-15647-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@plumgrid.com, netdev@vger.kernel.org
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54839 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753778AbaDGQzL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Apr 2014 12:55:11 -0400
In-Reply-To: <1396652643-15647-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Sat,  5 Apr 2014 01:04:03 +0200

> The old interpreter behaviour was that we returned with 0
> whenever we found a division by 0 would take place. In the new
> interpreter we would currently just skip that instead and
> continue execution.
> 
> It's true that a value of 0 as return might not be appropriate
> in all cases, but current users (socket filters -> drop
> packet, seccomp -> SECCOMP_RET_KILL, cls_bpf -> unclassified,
> etc) seem fine with that behaviour. Better this than undefined
> BPF program behaviour as it's expected that A contains the
> result of the division. In future, as more use cases open up,
> we could further adapt this return value to our needs, if
> necessary.
> 
> So reintroduce return of 0 for division by 0 as in the old
> interpreter. Also in case of K which is guaranteed to be 32bit
> wide, sk_chk_filter() already takes care of preventing division
> by 0 invoked through K, so we can generally spare us these tests.
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> Reviewed-by: Alexei Starovoitov <ast@plumgrid.com>

Applied, thanks Daniel.
