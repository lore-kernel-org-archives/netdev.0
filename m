From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net v2] samples/bpf: fix a build issue
Date: Tue, 11 Jul 2017 22:02:27 +0200
Message-ID: <59652ED3.5020607@iogearbox.net>
References: <20170710210428.1292358-1-yhs@fb.com> <20170711215114.4726d1da@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ast@fb.com, brakmo@fb.com, netdev@vger.kernel.org,
        kernel-team@fb.com
To: Jesper Dangaard Brouer <brouer@redhat.com>,
        Yonghong Song <yhs@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:58888 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932446AbdGKUCd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Jul 2017 16:02:33 -0400
In-Reply-To: <20170711215114.4726d1da@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/11/2017 09:51 PM, Jesper Dangaard Brouer wrote:
> On Mon, 10 Jul 2017 14:04:28 -0700 Yonghong Song <yhs@fb.com> wrote:
>
>> With latest net-next:
>> ====
>> clang  -nostdinc -isystem /usr/lib/gcc/x86_64-redhat-linux/6.3.1/include -I./arch/x86/include -I./arch/x86/include/generated/uapi -I./arch/x86/include/generated  -I./include -I./arch/x86/include/uapi -I./include/uapi -I./include/generated/uapi -include ./include/linux/kconfig.h  -Isamples/bpf \
>>      -D__KERNEL__ -D__ASM_SYSREG_H -Wno-unused-value -Wno-pointer-sign \
>>      -Wno-compare-distinct-pointer-types \
>>      -Wno-gnu-variable-sized-type-not-at-end \
>>      -Wno-address-of-packed-member -Wno-tautological-compare \
>>      -Wno-unknown-warning-option \
>>      -O2 -emit-llvm -c samples/bpf/tcp_synrto_kern.c -o -| llc -march=bpf -filetype=obj -o samples/bpf/tcp_synrto_kern.o
>> samples/bpf/tcp_synrto_kern.c:20:10: fatal error: 'bpf_endian.h' file not found
>>            ^~~~~~~~~~~~~~
>> 1 error generated.
>> ====
>>
>> net has the same issue.
>>
>> Add support for ntohl and htonl in tools/testing/selftests/bpf/bpf_endian.h.
>
> I think this patch should have been split up in two patches. One where
> you fix the compile issue, and one where you add support for ntohl and
> htonl.  And you are also moving the file... I'm getting confused
> reading this patch.

Could have been done, sure. Patch is still straight forward and small as-is,
so I don't really mind having this user space code squashed together.
