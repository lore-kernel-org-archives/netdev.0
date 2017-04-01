From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH v2 net-next 3/6] tools/lib/bpf: expose
 bpf_program__set_type()
Date: Fri, 31 Mar 2017 22:46:36 -0700
Message-ID: <eefe4853-8963-b165-7771-79a86cc3b831@fb.com>
References: <20170331044543.4075183-1-ast@fb.com>
 <20170331044543.4075183-4-ast@fb.com>
 <a6aaf1e1-9c4e-ee4e-172e-9e9701aca96e@huawei.com>
 <9bf13cb9-c139-1706-d75e-e6e34d5136f6@fb.com>
 <f2fb0cf4-50fd-4623-1097-e2a8c42cc910@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Martin KaFai Lau <kafai@fb.com>, <netdev@vger.kernel.org>,
        <kernel-team@fb.com>
To: "Wangnan (F)" <wangnan0@huawei.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:60183 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750818AbdDAFrM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 1 Apr 2017 01:47:12 -0400
In-Reply-To: <f2fb0cf4-50fd-4623-1097-e2a8c42cc910@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/31/17 10:32 PM, Wangnan (F) wrote:
>
> OK. Then let your patch be merged first then let me do the code cleanup.

Thanks!

Once these two lib/bpf patches applied to net-next we can apply
the same to tip and there will be no conflicts during the merge
window.

I'm also planning to fix few things later:

- there is an obscure error
libbpf: relocation failed: no 11 section
It's printed when llvm generates access to global variables.
I think we need to improve the error message to point out the actual
reason of the failure, so the user can fix the program.

- there is another equally obscure error
libbpf: Program 'foo' contains non-map related relo data pointing to 
section 8
It's happening when program is compiled with -g.
It's just a bug in libbpf and the fix is straightforward.

so I suspect these fixes will also go into both net-next and tip.
