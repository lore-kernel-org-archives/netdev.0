From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] samples/bpf: fix a build issue
Date: Tue, 11 Jul 2017 20:51:50 -0700 (PDT)
Message-ID: <20170711.205150.1681331608402325782.davem@davemloft.net>
References: <20170710210428.1292358-1-yhs@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@fb.com, daniel@iogearbox.net, brakmo@fb.com,
        netdev@vger.kernel.org, kernel-team@fb.com
To: yhs@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47082 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751270AbdGLDvv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Jul 2017 23:51:51 -0400
In-Reply-To: <20170710210428.1292358-1-yhs@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yonghong Song <yhs@fb.com>
Date: Mon, 10 Jul 2017 14:04:28 -0700

> With latest net-next:
> ====
> clang  -nostdinc -isystem /usr/lib/gcc/x86_64-redhat-linux/6.3.1/include -I./arch/x86/include -I./arch/x86/include/generated/uapi -I./arch/x86/include/generated  -I./include -I./arch/x86/include/uapi -I./include/uapi -I./include/generated/uapi -include ./include/linux/kconfig.h  -Isamples/bpf \
>     -D__KERNEL__ -D__ASM_SYSREG_H -Wno-unused-value -Wno-pointer-sign \
>     -Wno-compare-distinct-pointer-types \
>     -Wno-gnu-variable-sized-type-not-at-end \
>     -Wno-address-of-packed-member -Wno-tautological-compare \
>     -Wno-unknown-warning-option \
>     -O2 -emit-llvm -c samples/bpf/tcp_synrto_kern.c -o -| llc -march=bpf -filetype=obj -o samples/bpf/tcp_synrto_kern.o
> samples/bpf/tcp_synrto_kern.c:20:10: fatal error: 'bpf_endian.h' file not found
>           ^~~~~~~~~~~~~~
> 1 error generated.
> ====
> 
> net has the same issue.
> 
> Add support for ntohl and htonl in tools/testing/selftests/bpf/bpf_endian.h.
> Also move bpf_helpers.h from samples/bpf to selftests/bpf and change
> compiler include logic so that programs in samples/bpf can access the headers
> in selftests/bpf, but not the other way around.
> 
> Signed-off-by: Yonghong Song <yhs@fb.com>

Applied, thanks.
