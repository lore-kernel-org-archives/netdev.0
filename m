From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 2/2] s390/bpf: fix bpf frame pointer setup
Date: Wed, 03 Jun 2015 19:32:17 -0700 (PDT)
Message-ID: <20150603.193217.279547964953271748.davem@davemloft.net>
References: <1433224115-28411-1-git-send-email-ast@plumgrid.com>
	<1433224115-28411-2-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: holzheu@linux.vnet.ibm.com, schwidefsky@de.ibm.com,
	heiko.carstens@de.ibm.com, daniel@iogearbox.net,
	netdev@vger.kernel.org
To: ast@plumgrid.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43353 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751809AbbFDCcS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jun 2015 22:32:18 -0400
In-Reply-To: <1433224115-28411-2-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@plumgrid.com>
Date: Mon,  1 Jun 2015 22:48:35 -0700

> From: Michael Holzheu <holzheu@linux.vnet.ibm.com>
> 
> Currently the bpf frame pointer is set to the old r15. This is
> wrong because of packed stack. Fix this and adjust the frame pointer
> to respect packed stack. This now generates a prolog like the following:
> 
>  3ff8001c3fa: eb67f0480024   stmg    %r6,%r7,72(%r15)
>  3ff8001c400: ebcff0780024   stmg    %r12,%r15,120(%r15)
>  3ff8001c406: b904001f       lgr     %r1,%r15      <- load backchain
>  3ff8001c40a: 41d0f048       la      %r13,72(%r15) <- load adjusted bfp
>  3ff8001c40e: a7fbfd98       aghi    %r15,-616
>  3ff8001c412: e310f0980024   stg     %r1,152(%r15) <- save backchain
> 
> Fixes: 054623105728 ("s390/bpf: Add s390x eBPF JIT compiler backend")
> Signed-off-by: Michael Holzheu <holzheu@linux.vnet.ibm.com>
> Acked-by: Heiko Carstens <heiko.carstens@de.ibm.com>
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>

Applied.
