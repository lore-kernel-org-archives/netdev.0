From: Yonghong Song <yhs@fb.com>
Subject: Re: [PATCH net v2] selftests/bpf: fix broken build due to types.h
Date: Wed, 17 May 2017 16:48:33 -0700
Message-ID: <5927830d-fac2-a204-47e7-78f0e4149afb@fb.com>
References: <20170517221805.1593973-1-yhs@fb.com>
 <591CD540.1040305@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <kernel-team@fb.com>
To: Daniel Borkmann <daniel@iogearbox.net>, <ast@fb.com>,
        <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:53535 "EHLO
        mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754058AbdEQXs5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 17 May 2017 19:48:57 -0400
In-Reply-To: <591CD540.1040305@iogearbox.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 5/17/17 3:57 PM, Daniel Borkmann wrote:
> On 05/18/2017 12:18 AM, Yonghong Song wrote:
>> Commit 0a5539f66133 ("bpf: Provide a linux/types.h override
>> for bpf selftests.") caused a build failure for 
>> tools/testing/selftest/bpf
>> because of some missing types:
>>      $ make -C tools/testing/selftests/bpf/
>>      ...
>>      In file included from 
>> /home/yhs/work/net-next/tools/testing/selftests/bpf/test_pkt_access.c:8:
>>      ../../../include/uapi/linux/bpf.h:170:3: error: unknown type name 
>> '__aligned_u64'
>>                      __aligned_u64   key;
>>      ...
>>      /usr/include/linux/swab.h:160:8: error: unknown type name 
>> '__always_inline'
>>      static __always_inline __u16 __swab16p(const __u16 *p)
>>      ...
>> The type __aligned_u64 is defined in linux:include/uapi/linux/types.h.
>>
>> The fix is to copy missing type definition into
>> tools/testing/selftests/bpf/include/uapi/linux/types.h.
>> Adding additional include "string.h" resolves __always_inline issue.
>>
>> Fixes: 0a5539f66133 ("bpf: Provide a linux/types.h override for bpf 
>> selftests.")
>> Signed-off-by: Yonghong Song <yhs@fb.com>
> 
> Can you elaborate why string.h specifically? Can't we define the
> __always_inline ourselves?

Actually, yes, we can define __always_inline ourselves in each bpf 
program or in some common header files used by all selftests bpf
programs.

I use string.h because several other bpf programs
(test_xdp.c test_l4lb.c test_tcp_estats.c) they all have
__always_inline and string.h, so they do not have issue.
I discovered this pattern so I just add string.h into test_pkt_access.c
as well.

string.h provides memset/memcpy prototypes which is used in bpf program 
(test_xdp.c and test_tcp_estats.c, but not test_l4lb.c and 
test_pkt_access.c).

Thanks,

Yonghong

> 
> Thanks,
> Daniel
