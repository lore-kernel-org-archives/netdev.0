From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] selftests/bpf: fix broken build due to types.h
Date: Wed, 17 May 2017 19:01:49 -0400 (EDT)
Message-ID: <20170517.190149.1446382466519323776.davem@davemloft.net>
References: <20170517221805.1593973-1-yhs@fb.com>
        <591CD540.1040305@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yhs@fb.com, ast@fb.com, netdev@vger.kernel.org, kernel-team@fb.com
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37674 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752750AbdEQXBw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 17 May 2017 19:01:52 -0400
In-Reply-To: <591CD540.1040305@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Thu, 18 May 2017 00:57:04 +0200

> On 05/18/2017 12:18 AM, Yonghong Song wrote:
>> Commit 0a5539f66133 ("bpf: Provide a linux/types.h override
>> for bpf selftests.") caused a build failure for
>> tools/testing/selftest/bpf
>> because of some missing types:
>>      $ make -C tools/testing/selftests/bpf/
>>      ...
>>      In file included from
>>      /home/yhs/work/net-next/tools/testing/selftests/bpf/test_pkt_access.c:8:
>>      ../../../include/uapi/linux/bpf.h:170:3: error: unknown type name
>>      '__aligned_u64'
>>                      __aligned_u64   key;
>>      ...
>>      /usr/include/linux/swab.h:160:8: error: unknown type name
>>      '__always_inline'
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

That way it comes from compiler.h

Probably it would have been better to have the BPF linux/types.h bring
it in.

Sorry I applied this so quickly, I wanted this regression fixed as fast
as possible.
