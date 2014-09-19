From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] sparc: bpf_jit: fix support for ldx/stx mem and
 SKF_AD_VLAN_TAG
Date: Fri, 19 Sep 2014 16:02:00 -0400 (EDT)
Message-ID: <20140919.160200.48663669220936853.davem@davemloft.net>
References: <1410917578-5122-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dborkman@redhat.com, netdev@vger.kernel.org
To: ast@plumgrid.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58711 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932250AbaISUCC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Sep 2014 16:02:02 -0400
In-Reply-To: <1410917578-5122-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@plumgrid.com>
Date: Tue, 16 Sep 2014 18:32:58 -0700

> fix several issues in sparc BPF JIT compiler.
> 
> ldx/stx related:
> . classic BPF instructions that access mem[] slots were not setting
>   SEEN_MEM flag, so stack wasn't allocated. Fix that by advertising
>   correct flags
> 
> . LDX/STX instructions were missing SEEN_XREG, so register value
>   could have leaked to user space. Fix it.
> 
> . since stack for mem[] slots is allocated with 'sub %sp' instead
>   of 'save %sp', use %sp as base register instead of %fp.
> 
> . ldx mem[0] means first slot in classic BPF which should have
>   -4 offset instead of 0.
> 
> . sparc64 needs 2047 stack bias as per ABI to access stack
> 
> . emit_stmem() was using LD32I macro instead of ST32I
> 
> SKF_AD_VLAN_TAG* related:
> . SKF_AD_VLAN_TAG_PRESENT must return 1 or 0 instead of '> 0' or 0
>   as per classic BPF de facto standard
> 
> . SKF_AD_VLAN_TAG needs to mask the field correctly
> 
> Fixes: 2809a2087cc4 ("net: filter: Just In Time compiler for sparc")
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>

Applied and queued up for -stable, thanks!
