From: "Wangnan (F)" <wangnan0@huawei.com>
Subject: Re: [PATCH net-next v1] bpf: Remove redundant ifdef
Date: Wed, 15 Feb 2017 08:52:48 +0800
Message-ID: <c0feec0d-46f0-9edb-e725-c8025ee2bcab@huawei.com>
References: <20170211193708.18191-1-mic@digikod.net>
 <f83892da-d672-8bf7-18e4-85de21deea84@huawei.com>
 <20170214.120743.1600921739599827036.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 8bit
Cc: <mic@digikod.net>, <linux-kernel@vger.kernel.org>, <ast@fb.com>,
        <daniel@iogearbox.net>, <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170214.120743.1600921739599827036.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 2017/2/15 1:07, David Miller wrote:
> From: "Wangnan (F)" <wangnan0@huawei.com>
> Date: Mon, 13 Feb 2017 09:53:49 +0800
>
>>
>> On 2017/2/12 3:37, Mickaël Salaün wrote:
>>> Remove a useless ifdef __NR_bpf as requested by Wang Nan.
>>>
>>> Inline one-line static functions as it was in the bpf_sys.h file.
>>>
>>> Signed-off-by: Mickaël Salaün <mic@digikod.net>
>>> Cc: Alexei Starovoitov <ast@fb.com>
>>> Cc: Daniel Borkmann <daniel@iogearbox.net>
>>> Cc: David S. Miller <davem@davemloft.net>
>>> Cc: Wang Nan <wangnan0@huawei.com>
>>> Link:
>>> https://lkml.kernel.org/r/828ab1ff-4dcf-53ff-c97b-074adb895006@huawei.com
>>> ---
>>>    tools/lib/bpf/bpf.c | 12 +++---------
>>>    1 file changed, 3 insertions(+), 9 deletions(-)
>>>
>>> diff --git a/tools/lib/bpf/bpf.c b/tools/lib/bpf/bpf.c
>>> index 50e04cc5dddd..2de9c386989a 100644
>>> --- a/tools/lib/bpf/bpf.c
>>> +++ b/tools/lib/bpf/bpf.c
>>> @@ -42,21 +42,15 @@
>>>    # endif
>>>    #endif
>>>    -static __u64 ptr_to_u64(const void *ptr)
>>> +static inline __u64 ptr_to_u64(const void *ptr)
>>>    {
>>>    	return (__u64) (unsigned long) ptr;
>>>    }
>>>    -static int sys_bpf(enum bpf_cmd cmd, union bpf_attr *attr,
>>> -		   unsigned int size)
>>> +static inline int sys_bpf(enum bpf_cmd cmd, union bpf_attr *attr,
>>> +			  unsigned int size)
>>>    {
>>> -#ifdef __NR_bpf
>>>    	return syscall(__NR_bpf, cmd, attr, size);
>>> -#else
>>> -	fprintf(stderr, "No bpf syscall, kernel headers too old?\n");
>>> -	errno = ENOSYS;
>>> -	return -1;
>>> -#endif
>>>    }
>>>      int bpf_create_map(enum bpf_map_type map_type, int key_size,
>> Acked-by: Wang Nan <wangnan0@huawei.com>
>>
>> However, it is better to merge this patch with commit
>> 702498a1426bc95b6f49f9c5fba616110cbd3947.
> I don't know where this commit ID is.  Since this patch is targetting
> net-next I would expect a commit ID with not context to be in that
> tree.  Please always specify where the commit ID you mention is.

It is "bpf: Remove bpf_sys.h from selftests" in net-next.


> Futhermore, commits in net-next are permanent so it is not possible
> afterwards to "merge this patch with commit X".

I understand. Maintainers sometime reset
his/her head to an early version and amend
the commit to make the history clean, but
clearly net-next never do this.

Thank you.
