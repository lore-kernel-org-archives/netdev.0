From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: filter: fix SKF_AD_PKTTYPE extension on
 big-endian
Date: Thu, 05 Jun 2014 15:41:17 -0700 (PDT)
Message-ID: <20140605.154117.1636370741582387143.davem@davemloft.net>
References: <1402004376-1814-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dborkman@redhat.com, netdev@vger.kernel.org
To: ast@plumgrid.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51702 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751984AbaFEWlS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2014 18:41:18 -0400
In-Reply-To: <1402004376-1814-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@plumgrid.com>
Date: Thu,  5 Jun 2014 14:39:36 -0700

> BPF classic->internal converter broke SKF_AD_PKTTYPE extension, since
> pkt_type_offset() was failing to find skb->pkt_type field which is defined as:
> __u8 pkt_type:3,
>      fclone:2,
>      ipvs_property:1,
>      peeked:1,
>      nf_trace:1;
> 
> Fix it by searching for 3 most significant bits and shift them by 5 at run-time
> 
> Fixes: bd4cf0ed331a ("net: filter: rework/optimize internal BPF interpreter's instruction set")
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
> Acked-by: Daniel Borkmann <dborkman@redhat.com>
> Tested-by: Daniel Borkmann <dborkman@redhat.com>
> ---
> 
> backported BPF testsuite to 'net' and tested with qemu-sparc64.
> Daniel tested it on s390.
> 
> Dave,
> The fix doesn't apply cleanly to 'net-next'.
> There 2nd hunk needs to be:
>                insn++;
>                *insn = BPF_ALU32_IMM(BPF_RSH, BPF_REG_A, 5);
> I have 'net-next' patch ready and tested as well. Let me know if I should
> send it or you'll take care of it while doing the merge of 'net'.

Applied, and I'll take care of this when I merge net into net-next,
thanks.
