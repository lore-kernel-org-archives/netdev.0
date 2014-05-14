From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: Re: [PATCH net] net: filter: x86: fix JIT address randomization
Date: Wed, 14 May 2014 09:36:56 +0200
Message-ID: <20140514073656.GA9848@osiris>
References: <1400007214-3236-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Daniel Borkmann <dborkman@redhat.com>, netdev@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp13.uk.ibm.com ([195.75.94.109]:57313 "EHLO
	e06smtp13.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751589AbaENHhC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2014 03:37:02 -0400
Received: from /spool/local
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <heiko.carstens@de.ibm.com>;
	Wed, 14 May 2014 08:37:00 +0100
Received: from b06cxnps4076.portsmouth.uk.ibm.com (d06relay13.portsmouth.uk.ibm.com [9.149.109.198])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id 67AF61B08076
	for <netdev@vger.kernel.org>; Wed, 14 May 2014 08:37:12 +0100 (BST)
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s4E7awnJ655868
	for <netdev@vger.kernel.org>; Wed, 14 May 2014 07:36:58 GMT
Received: from d06av01.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s4E7auS9024676
	for <netdev@vger.kernel.org>; Wed, 14 May 2014 01:36:57 -0600
Content-Disposition: inline
In-Reply-To: <1400007214-3236-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 13, 2014 at 11:53:34AM -0700, Alexei Starovoitov wrote:
> bpf_alloc_binary() adds 128 bytes of room to JITed program image
> and rounds it up to the nearest page size. If image size is close
> to page size (like 4000), it is rounded to two pages:
> round_up(4000 + 4 + 128) == 8192
> then 'hole' is computed as 8192 - (4000 + 4) = 4188
> If prandom_u32() % hole selects a number >= 4096, then kernel will crash
> during bpf_jit_free():

[...]

> Fixes: 314beb9bcabfd ("x86: bpf_jit_comp: secure bpf jit against spraying attacks")
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
> ---
> 
> s390 commit aa2d2c73c21f ("s390/bpf,jit: address randomize and write protect jit code")
> seems to have the same problem

Yes, that's the same bug on s390. Would you mind fixing s390 as well, since I
assume you're going to send a new patch for x86?

Would be good to keep the code quite identical so these issues can be easily
seen across architectures.
