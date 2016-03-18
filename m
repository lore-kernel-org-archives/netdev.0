From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] cls_bpf: reset class and reuse major in da
Date: Fri, 18 Mar 2016 19:35:47 -0400 (EDT)
Message-ID: <20160318.193547.1427258902252761452.davem@davemloft.net>
References: <9e700a6f163815e6f79db50e7a8f9f52696f28e7.1458075641.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56610 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751948AbcCRXft (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Mar 2016 19:35:49 -0400
In-Reply-To: <9e700a6f163815e6f79db50e7a8f9f52696f28e7.1458075641.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Tue, 15 Mar 2016 22:41:22 +0100

> There are two issues with the current code. First one is that we need
> to set res->class to 0 in case we use non-default classid matching.
> 
> This is important for the case where cls_bpf was initially set up with
> an optional binding to a default class with tcf_bind_filter(), where
> the underlying qdisc implements bind_tcf() that fills res->class and
> tests for it later on when doing the classification. Convention for
> these cases is that after tc_classify() was called, such qdiscs (atm,
> drr, qfq, cbq, hfsc, htb) first test class, and if 0, then they lookup
> based on classid.
> 
> Second, there's a bug with da mode, where res->classid is only assigned
> a 16 bit minor, but it needs to expand to the full 32 bit major/minor
> combination instead, therefore we need to expand with the bound major.
> This is fine as classes belonging to a classful qdisc must share the
> same major.
> 
> Fixes: 045efa82ff56 ("cls_bpf: introduce integrated actions")
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> Acked-by: Alexei Starovoitov <ast@kernel.org>

Applied, thanks Daniel.
