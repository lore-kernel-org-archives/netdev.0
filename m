From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: Re: [PATCH net-next 1/3] net: bpf: consolidate JIT binary allocator
Date: Mon, 8 Sep 2014 08:17:44 +0200
Message-ID: <20140908061744.GA4193@osiris>
References: <1409996567-2170-1-git-send-email-dborkman@redhat.com>
 <1409996567-2170-2-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, ast@plumgrid.com, netdev@vger.kernel.org,
	Eric Dumazet <edumazet@google.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp10.uk.ibm.com ([195.75.94.106]:43351 "EHLO
	e06smtp10.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751483AbaIHGRt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2014 02:17:49 -0400
Received: from /spool/local
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <heiko.carstens@de.ibm.com>;
	Mon, 8 Sep 2014 07:17:48 +0100
Received: from b06cxnps4076.portsmouth.uk.ibm.com (d06relay13.portsmouth.uk.ibm.com [9.149.109.198])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id BA28F17D8024
	for <netdev@vger.kernel.org>; Mon,  8 Sep 2014 07:19:45 +0100 (BST)
Received: from d06av10.portsmouth.uk.ibm.com (d06av10.portsmouth.uk.ibm.com [9.149.37.251])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id s886Hjkj44564646
	for <netdev@vger.kernel.org>; Mon, 8 Sep 2014 06:17:45 GMT
Received: from d06av10.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av10.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s886Hig2024561
	for <netdev@vger.kernel.org>; Mon, 8 Sep 2014 00:17:45 -0600
Content-Disposition: inline
In-Reply-To: <1409996567-2170-2-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Sep 06, 2014 at 11:42:45AM +0200, Daniel Borkmann wrote:
> Introduced in commit 314beb9bcabf ("x86: bpf_jit_comp: secure bpf jit
> against spraying attacks") and later on replicated in aa2d2c73c21f
> ("s390/bpf,jit: address randomize and write protect jit code") for
> s390 architecture, write protection for BPF JIT images got added and
> a random start address of the JIT code, so that it's not on a page
> boundary anymore.
> 
> Since both use a very similar allocator for the BPF binary header,
> we can consolidate this code into the BPF core as it's mostly JIT
> independant anyway.
> 
> This will also allow for future archs that support DEBUG_SET_MODULE_RONX
> to just reuse instead of reimplementing it.
> 
> While reviewing the code, I think on s390, the alignment masking
> seems not to be correct in it's current form, that is, we make sure
> the first instruction starts at an even address as stated by commit
> aa2d2c73c21f but masks the start with '& -2' while 2 byte-alignment
> should rather be '& ~1'.
> 
> JIT tested on x86_64 and s390x with BPF test suite.
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> Acked-by: Alexei Starovoitov <ast@plumgrid.com>
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
> Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
> ---
>  arch/s390/net/bpf_jit_comp.c | 45 ++++++++-------------------------------
>  arch/x86/net/bpf_jit_comp.c  | 50 ++++++++++----------------------------------
>  include/linux/filter.h       | 13 ++++++++++++
>  kernel/bpf/core.c            | 39 ++++++++++++++++++++++++++++++++++
>  4 files changed, 72 insertions(+), 75 deletions(-)

Looks good to me (except for the comment about s390 ;).

Acked-by: Heiko Carstens <heiko.carstens@de.ibm.com>
