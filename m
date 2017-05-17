From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] selftests/bpf: fix broken build due to types.h
Date: Wed, 17 May 2017 18:45:28 -0400 (EDT)
Message-ID: <20170517.184528.1442090804651569316.davem@davemloft.net>
References: <20170517221805.1593973-1-yhs@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@fb.com, daniel@iogearbox.net, netdev@vger.kernel.org,
        kernel-team@fb.com
To: yhs@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37570 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751957AbdEQWpc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 17 May 2017 18:45:32 -0400
In-Reply-To: <20170517221805.1593973-1-yhs@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yonghong Song <yhs@fb.com>
Date: Wed, 17 May 2017 15:18:05 -0700

> Commit 0a5539f66133 ("bpf: Provide a linux/types.h override
> for bpf selftests.") caused a build failure for tools/testing/selftest/bpf
> because of some missing types:
>     $ make -C tools/testing/selftests/bpf/
>     ...
>     In file included from /home/yhs/work/net-next/tools/testing/selftests/bpf/test_pkt_access.c:8:
>     ../../../include/uapi/linux/bpf.h:170:3: error: unknown type name '__aligned_u64'
>                     __aligned_u64   key;
>     ...
>     /usr/include/linux/swab.h:160:8: error: unknown type name '__always_inline'
>     static __always_inline __u16 __swab16p(const __u16 *p)
>     ...
> The type __aligned_u64 is defined in linux:include/uapi/linux/types.h.
> 
> The fix is to copy missing type definition into
> tools/testing/selftests/bpf/include/uapi/linux/types.h.
> Adding additional include "string.h" resolves __always_inline issue.
> 
> Fixes: 0a5539f66133 ("bpf: Provide a linux/types.h override for bpf selftests.")
> Signed-off-by: Yonghong Song <yhs@fb.com>

Applied, thank you.
