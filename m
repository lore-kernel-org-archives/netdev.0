From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v1] bpf: Remove redundant ifdef
Date: Tue, 14 Feb 2017 12:07:43 -0500 (EST)
Message-ID: <20170214.120743.1600921739599827036.davem@davemloft.net>
References: <20170211193708.18191-1-mic@digikod.net>
        <f83892da-d672-8bf7-18e4-85de21deea84@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: mic@digikod.net, linux-kernel@vger.kernel.org, ast@fb.com,
        daniel@iogearbox.net, netdev@vger.kernel.org
To: wangnan0@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36864 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754888AbdBNRHp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Feb 2017 12:07:45 -0500
In-Reply-To: <f83892da-d672-8bf7-18e4-85de21deea84@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Wangnan (F)" <wangnan0@huawei.com>
Date: Mon, 13 Feb 2017 09:53:49 +0800

> 
> 
> On 2017/2/12 3:37, Mickaël Salaün wrote:
>> Remove a useless ifdef __NR_bpf as requested by Wang Nan.
>>
>> Inline one-line static functions as it was in the bpf_sys.h file.
>>
>> Signed-off-by: Mickaël Salaün <mic@digikod.net>
>> Cc: Alexei Starovoitov <ast@fb.com>
>> Cc: Daniel Borkmann <daniel@iogearbox.net>
>> Cc: David S. Miller <davem@davemloft.net>
>> Cc: Wang Nan <wangnan0@huawei.com>
>> Link:
>> https://lkml.kernel.org/r/828ab1ff-4dcf-53ff-c97b-074adb895006@huawei.com
>> ---
>>   tools/lib/bpf/bpf.c | 12 +++---------
>>   1 file changed, 3 insertions(+), 9 deletions(-)
>>
>> diff --git a/tools/lib/bpf/bpf.c b/tools/lib/bpf/bpf.c
>> index 50e04cc5dddd..2de9c386989a 100644
>> --- a/tools/lib/bpf/bpf.c
>> +++ b/tools/lib/bpf/bpf.c
>> @@ -42,21 +42,15 @@
>>   # endif
>>   #endif
>>   -static __u64 ptr_to_u64(const void *ptr)
>> +static inline __u64 ptr_to_u64(const void *ptr)
>>   {
>>   	return (__u64) (unsigned long) ptr;
>>   }
>>   -static int sys_bpf(enum bpf_cmd cmd, union bpf_attr *attr,
>> -		   unsigned int size)
>> +static inline int sys_bpf(enum bpf_cmd cmd, union bpf_attr *attr,
>> +			  unsigned int size)
>>   {
>> -#ifdef __NR_bpf
>>   	return syscall(__NR_bpf, cmd, attr, size);
>> -#else
>> -	fprintf(stderr, "No bpf syscall, kernel headers too old?\n");
>> -	errno = ENOSYS;
>> -	return -1;
>> -#endif
>>   }
>>     int bpf_create_map(enum bpf_map_type map_type, int key_size,
> 
> Acked-by: Wang Nan <wangnan0@huawei.com>
> 
> However, it is better to merge this patch with commit
> 702498a1426bc95b6f49f9c5fba616110cbd3947.

I don't know where this commit ID is.  Since this patch is targetting
net-next I would expect a commit ID with not context to be in that
tree.  Please always specify where the commit ID you mention is.

Futhermore, commits in net-next are permanent so it is not possible
afterwards to "merge this patch with commit X".
