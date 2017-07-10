From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net] samples/bpf: fix a build issue
Date: Mon, 10 Jul 2017 23:02:10 +0200
Message-ID: <5963EB52.706@iogearbox.net>
References: <20170710201224.1071186-1-yhs@fb.com> <5963E32E.2020105@iogearbox.net> <433e8dfa-f392-55d9-64cb-0a216f35fa65@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kernel-team@fb.com, Yonghong Song <yhs@localhost.localdomain>
To: Yonghong Song <yhs@fb.com>, ast@fb.com, brakmo@fb.com,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:35821 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754641AbdGJVCS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Jul 2017 17:02:18 -0400
In-Reply-To: <433e8dfa-f392-55d9-64cb-0a216f35fa65@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/10/2017 10:51 PM, Yonghong Song wrote:
> On 7/10/17 1:27 PM, Daniel Borkmann wrote:
>> On 07/10/2017 10:12 PM, Yonghong Song wrote:
>>> From: Yonghong Song <yhs@localhost.localdomain>
>>>
>>> With latest net-next:
>>> ====
>>> clang  -nostdinc -isystem /usr/lib/gcc/x86_64-redhat-linux/6.3.1/include -I./arch/x86/include -I./arch/x86/include/generated/uapi -I./arch/x86/include/generated -I./include -I./arch/x86/include/uapi -I./include/uapi -I./include/generated/uapi -include ./include/linux/kconfig.h -Isamples/bpf \
>>>     -D__KERNEL__ -D__ASM_SYSREG_H -Wno-unused-value -Wno-pointer-sign \
>>>     -Wno-compare-distinct-pointer-types \
>>>     -Wno-gnu-variable-sized-type-not-at-end \
>>>     -Wno-address-of-packed-member -Wno-tautological-compare \
>>>     -Wno-unknown-warning-option \
>>>     -O2 -emit-llvm -c samples/bpf/tcp_synrto_kern.c -o -| llc -march=bpf -filetype=obj -o samples/bpf/tcp_synrto_kern.o
>>> samples/bpf/tcp_synrto_kern.c:20:10: fatal error: 'bpf_endian.h' file not found
>>>           ^~~~~~~~~~~~~~
>>> 1 error generated.
>>> ====
>>>
>>> net has the same issue.
>>>
>>> Add support for ntohl and htonl in tools/testing/selftests/bpf/bpf_endian.h
>>> and move it to samples/bpf/ directory so that it can used by
>>> both selftests/bpf and samples/bpf. The existing samples/bpf/bpf_helpers.h
>>> is already used by both.
>>>
>>> Signed-off-by: Yonghong Song <yhs@fb.com>
>>> ---
>>>   {tools/testing/selftests => samples}/bpf/bpf_endian.h | 14 ++++++++++++++
>>
>> samples/bpf/Makefile already does:
>>
>>    HOSTCFLAGS += -I$(srctree)/tools/testing/selftests/bpf/
>>
>> If needed we should rather extend the sample's Makefile to pull in
>> bpf_endian.h also for clang generated files, but not the other way
>> round. It's both kind of messy, but kernel selftests should not need
>> to include or depend upon some sample code.
>
> Sounds good. I will then move bpf_helpers.h to selftests as well so
> samples/bpf will depend on selftests/bpf, but not the other way around.

Okay, that's fine by me. (We can later also move some of the test
cases over to selftests, so that they get generally more coverage.)
Thanks, Yonghong!
