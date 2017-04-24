From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH] sparc64: Support cbcond instructions in eBPF JIT.
Date: Mon, 24 Apr 2017 16:09:17 -0700
Message-ID: <fe249a31-37f9-7c07-7592-15d9af5d4523@fb.com>
References: <20170424.190228.571734658408906331.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <daniel@iogearbox.net>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:57804 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S979153AbdDXXJn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2017 19:09:43 -0400
In-Reply-To: <20170424.190228.571734658408906331.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/24/17 4:02 PM, David Miller wrote:
>
> cbcond combines a compare with a branch into a single instruction.
>
> The limitations are:
>
> 1) Only newer chips support it
>
> 2) For immediate compares we are limited to 5-bit signed immediate
>    values
>
> 3) The branch displacement is limited to 10-bit signed
>
> 4) We cannot use it for JSET

llvm doesn't know how to generate it yet. So it's only seen after
classic->extended conversion.
Hence not a concern at all for this optimization.

> Also, cbcond (unlike all other sparc control transfers) lacks a delay
> slot.
>
> Currently we don't have a useful instruction we can push into the
> delay slot of normal branches.  So using cbcond pretty much always
> increases code density, and is therefore a win.
>
> Signed-off-by: David S. Miller <davem@davemloft.net>

Nice!
Acked-by: Alexei Starovoitov <ast@kernel.org>

That puts up a pressure to optimize x64 JIT too :)
