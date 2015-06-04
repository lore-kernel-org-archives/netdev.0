From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/2] s390/bpf: fix stack allocation
Date: Wed, 03 Jun 2015 19:32:04 -0700 (PDT)
Message-ID: <20150603.193204.215182154047808316.davem@davemloft.net>
References: <1433224115-28411-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: holzheu@linux.vnet.ibm.com, schwidefsky@de.ibm.com,
	heiko.carstens@de.ibm.com, daniel@iogearbox.net,
	netdev@vger.kernel.org
To: ast@plumgrid.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43341 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751081AbbFDCcI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jun 2015 22:32:08 -0400
In-Reply-To: <1433224115-28411-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@plumgrid.com>
Date: Mon,  1 Jun 2015 22:48:34 -0700

> From: Michael Holzheu <holzheu@linux.vnet.ibm.com>
> 
> On s390x we have to provide 160 bytes stack space before we can call
> the next function. From the 160 bytes that we got from the previous
> function we only use 11 * 8 bytes and have 160 - 11 * 8 bytes left.
> Currently for BPF we allocate additional 160 - 11 * 8 bytes for the
> next function. This is wrong because then the next function only gets:
> 
>  (160 - 11 * 8) + (160 - 11 * 8) = 2 * 72 = 144 bytes
> 
> Fix this and allocate enough memory for the next function.
> 
> Fixes: 054623105728 ("s390/bpf: Add s390x eBPF JIT compiler backend")
> Signed-off-by: Michael Holzheu <holzheu@linux.vnet.ibm.com>
> Acked-by: Heiko Carstens <heiko.carstens@de.ibm.com>
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>

Applied.
