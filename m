From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net v2] samples/bpf: fix a build issue
Date: Mon, 10 Jul 2017 23:13:10 +0200
Message-ID: <5963EDE6.60408@iogearbox.net>
References: <20170710210428.1292358-1-yhs@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kernel-team@fb.com
To: Yonghong Song <yhs@fb.com>, ast@fb.com, brakmo@fb.com,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:37094 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754020AbdGJVNl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Jul 2017 17:13:41 -0400
In-Reply-To: <20170710210428.1292358-1-yhs@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/10/2017 11:04 PM, Yonghong Song wrote:
> With latest net-next:
> ====
> clang  -nostdinc -isystem /usr/lib/gcc/x86_64-redhat-linux/6.3.1/include -I./arch/x86/include -I./arch/x86/include/generated/uapi -I./arch/x86/include/generated  -I./include -I./arch/x86/include/uapi -I./include/uapi -I./include/generated/uapi -include ./include/linux/kconfig.h  -Isamples/bpf \
>      -D__KERNEL__ -D__ASM_SYSREG_H -Wno-unused-value -Wno-pointer-sign \
>      -Wno-compare-distinct-pointer-types \
>      -Wno-gnu-variable-sized-type-not-at-end \
>      -Wno-address-of-packed-member -Wno-tautological-compare \
>      -Wno-unknown-warning-option \
>      -O2 -emit-llvm -c samples/bpf/tcp_synrto_kern.c -o -| llc -march=bpf -filetype=obj -o samples/bpf/tcp_synrto_kern.o
> samples/bpf/tcp_synrto_kern.c:20:10: fatal error: 'bpf_endian.h' file not found
>            ^~~~~~~~~~~~~~
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

LGTM, thanks!

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
