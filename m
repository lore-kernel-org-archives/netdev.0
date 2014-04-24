From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: Re: [PATCH net] net: filter: initialize A and X registers
Date: Thu, 24 Apr 2014 09:07:12 +0200
Message-ID: <20140424090712.489f9bc5@mschwide>
References: <1398223137-5463-1-git-send-email-ast@plumgrid.com>
	<20140422.235745.1219194947074686642.davem@davemloft.net>
	<CAMEtUux=mOyZkfxMWi3eA01TvmJrfJpeBpGcHvheptcckA=dzQ@mail.gmail.com>
	<20140423.125043.100674358164503915.davem@davemloft.net>
	<CAMEtUuwaEb5OgZHCYL-pJRrvLRWBqA1sXhg3diO3=K7ephyBpA@mail.gmail.com>
	<1398289142.29914.23.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAMEtUuy-n4=YxejsCF0gg2VX1csfW5p8SfwggH2Tzi6XvE_htw@mail.gmail.com>
	<1398308109.29914.61.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast@plumgrid.com>,
	David Miller <davem@davemloft.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	Network Development <netdev@vger.kernel.org>,
	Heiko Carstens <heiko.carstens@de.ibm.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp15.uk.ibm.com ([195.75.94.111]:52700 "EHLO
	e06smtp15.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750860AbaDXHH0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2014 03:07:26 -0400
Received: from /spool/local
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <schwidefsky@de.ibm.com>;
	Thu, 24 Apr 2014 08:07:24 +0100
Received: from b06cxnps3074.portsmouth.uk.ibm.com (d06relay09.portsmouth.uk.ibm.com [9.149.109.194])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id 39FF017D804E
	for <netdev@vger.kernel.org>; Thu, 24 Apr 2014 08:08:16 +0100 (BST)
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s3O77Gct590086
	for <netdev@vger.kernel.org>; Thu, 24 Apr 2014 07:07:16 GMT
Received: from d06av01.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s3O77Fat000375
	for <netdev@vger.kernel.org>; Thu, 24 Apr 2014 01:07:16 -0600
In-Reply-To: <1398308109.29914.61.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 23 Apr 2014 19:55:09 -0700
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> On Wed, 2014-04-23 at 15:19 -0700, Alexei Starovoitov wrote:
> 
> > yes, x86 jit is smart to deal around this problem in an efficient way.
> > sparc/arm jits copy pasted the idea correctly.
> 
> Well... not really smart, but sufficient enough (even if I am sure we
> probably have some bugs)
> 
> > but s390 jit seems to have a bug, since it's not clearing A
> > when 1st insn is BPF_S_LDX_B_MSH
> 
> Sure, JIT is hard and quite risky (You forgot to CC Heiko & Martin, they
> probably can send the needed patch)

That should be a one-line patch which removes the BPF_S_LDX_B_MSH opcode
from the switch statement in bpf_jit_noleaks.

-- 
blue skies,
   Martin.

"Reality continues to ruin my life." - Calvin.
