From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [RFC 4/4] bpf: Restrict Checmate bpf programs to current kernel
 ABI
Date: Thu, 04 Aug 2016 11:54:45 +0200
Message-ID: <57A310E5.7030000@iogearbox.net>
References: <20160804071227.GA19135@ircssh.c.rugged-nimbus-611.internal> <57A31070.8090602@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com,
	linux-security-module@vger.kernel.org, netdev@vger.kernel.org
To: Sargun Dhillon <sargun@sargun.me>, linux-kernel@vger.kernel.org
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <57A31070.8090602@iogearbox.net>
Sender: owner-linux-security-module@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/04/2016 11:52 AM, Daniel Borkmann wrote:
> On 08/04/2016 09:12 AM, Sargun Dhillon wrote:
>> I think it makes sense to restrict Checmate to loading programs that have been
>> compiled with the current kernel ABI. We can further stabilize the ABI, and
>> perhaps lift this restriction later.
>>
>> Signed-off-by: Sargun Dhillon <sargun@sargun.me>
>> ---
>>   kernel/bpf/syscall.c         | 2 +-
>>   samples/bpf/checmate1_kern.c | 3 ++-
>>   2 files changed, 3 insertions(+), 2 deletions(-)
>>
>> diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
>> index 228f962..2a37b4d 100644
>> --- a/kernel/bpf/syscall.c
>> +++ b/kernel/bpf/syscall.c
>> @@ -741,7 +741,7 @@ static int bpf_prog_load(union bpf_attr *attr)
>>       if (attr->insn_cnt >= BPF_MAXINSNS)
>>           return -EINVAL;
>>
>> -    if (type == BPF_PROG_TYPE_KPROBE &&
>> +    if ((type & (BPF_PROG_TYPE_KPROBE | BPF_PROG_TYPE_CHECMATE)) &&
>>           attr->kern_version != LINUX_VERSION_CODE)
>
> Btw, this check is correct, program types are not masks.

Sorry, I meant to write *not* correct, which was hopefully inferable from
the rest.

> BPF_PROG_TYPE_KPROBE (== 2) and BPF_PROG_TYPE_CHECMATE (== 7) will now
> require every type to have a version code ...
>
>>           return -EINVAL;
>>
