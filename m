From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] net: filter: fix length calculation in BPF
 testsuite
Date: Mon, 02 Jun 2014 16:33:14 -0700 (PDT)
Message-ID: <20140602.163314.1117003983759957990.davem@davemloft.net>
References: <53879B78.5050106@redhat.com>
	<1401470112-3933-1-git-send-email-chema@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, dborkman@redhat.com, ast@plumgrid.com,
	netdev@vger.kernel.org
To: chema@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37727 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751318AbaFBXdP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2014 19:33:15 -0400
In-Reply-To: <1401470112-3933-1-git-send-email-chema@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chema Gonzalez <chema@google.com>
Date: Fri, 30 May 2014 10:15:12 -0700

> The current probe_filter_length() (the function that calculates the
> length of a test BPF filter) behavior is to declare the end of the
> filter as soon as it finds {0, *, *, 0}. This is actually a valid
> insn ("ld #0"), so any filter with includes "BPF_STMT(BPF_LD | BPF_IMM, 0)"
> fails (its length is cut short).
> 
> We are changing probe_filter_length() so as to start from the end, and
> declare the end of the filter as the first instruction which is not
> {0, *, *, 0}. This solution produces a simpler patch than the
> alternative of using an explicit end-of-filter mark. It is technically
> incorrect if your filter ends up with "ld #0", but that should not
> happen anyway.
> 
> We also add a new test (LD_IMM_0) that includes ld #0 (does not work
> without this patch).
> 
> Signed-off-by: Chema Gonzalez <chema@google.com>

Applied, thank you.
