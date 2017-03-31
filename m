From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH v2 net-next 3/6] tools/lib/bpf: expose
 bpf_program__set_type()
Date: Fri, 31 Mar 2017 16:28:51 -0700
Message-ID: <6ae6a0af-6b25-0c9d-9230-2d52e7203e6c@fb.com>
References: <20170331044543.4075183-1-ast@fb.com>
 <20170331044543.4075183-4-ast@fb.com>
 <61323557-be03-6e4a-8b02-a20c63d10b20@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Martin KaFai Lau <kafai@fb.com>, <netdev@vger.kernel.org>,
        <kernel-team@fb.com>
To: "Wangnan (F)" <wangnan0@huawei.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:51726 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1753724AbdCaX3V (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 31 Mar 2017 19:29:21 -0400
In-Reply-To: <61323557-be03-6e4a-8b02-a20c63d10b20@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/31/17 12:49 AM, Wangnan (F) wrote:
> Hi Alexei,
>
> Please see the patch I sent. Since we export bpf_program__set_type(),
> bpf_program__set_xxx() should be built based on it.

Replied to your patch. I still think simply adding
#include <linux/bpf.h> here like I did in this patch is much cleaner.
That's the whole purpose of uapi header to be used in such libraries
and apps. Copy-pasting enum bpf_prog_type from bpf.h into bunch of
macros in libbpf.h just doesn't look right and likely an indication
that whatever you do with your proprietary stuff is fragile.
Clearly you're trying to avoid including bpf.h not because of perf,
which has its own copy of bpf.h in tools/include/
Just like iproute2 has its copy of bpf.h as well.
