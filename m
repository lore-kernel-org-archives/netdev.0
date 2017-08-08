From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH 2/2] bpf: Initialise mod[] in bpf_trace_printk
Date: Tue, 08 Aug 2017 09:48:57 -0700 (PDT)
Message-ID: <20170808.094857.245786887664041622.davem@davemloft.net>
References: <20170807222514.24292-1-james.hogan@imgtec.com>
        <20170807222514.24292-3-james.hogan@imgtec.com>
        <59897A7C.10009@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: james.hogan@imgtec.com, ast@kernel.org,
        linux-kernel@vger.kernel.org, rostedt@goodmis.org,
        mingo@redhat.com, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <59897A7C.10009@iogearbox.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Tue, 08 Aug 2017 10:46:52 +0200

> On 08/08/2017 12:25 AM, James Hogan wrote:
>> In bpf_trace_printk(), the elements in mod[] are left uninitialised,
>> but
>> they are then incremented to track the width of the formats. Zero
>> initialise the array just in case the memory contains non-zero values
>> on
>> entry.
>>
>> Fixes: 9c959c863f82 ("tracing: Allow BPF programs to call
>> bpf_trace_printk()")
>> Signed-off-by: James Hogan <james.hogan@imgtec.com>
>> Cc: Alexei Starovoitov <ast@kernel.org>
>> Cc: Daniel Borkmann <daniel@iogearbox.net>
>> Cc: Steven Rostedt <rostedt@goodmis.org>
>> Cc: Ingo Molnar <mingo@redhat.com>
>> Cc: netdev@vger.kernel.org
>> ---
>> When I checked (on MIPS32), the elements tended to have the value zero
>> anyway (does BPF zero the stack or something clever?), so this is a
>> purely theoretical fix.
>> ---
>>   kernel/trace/bpf_trace.c | 2 +-
>>   1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/kernel/trace/bpf_trace.c b/kernel/trace/bpf_trace.c
>> index 32dcbe1b48f2..86a52857d941 100644
>> --- a/kernel/trace/bpf_trace.c
>> +++ b/kernel/trace/bpf_trace.c
>> @@ -129,7 +129,7 @@ BPF_CALL_5(bpf_trace_printk, char *, fmt, u32,
>> fmt_size, u64, arg1,
>>   	   u64, arg2, u64, arg3)
>>   {
>>   	bool str_seen = false;
>> -	int mod[3] = {};
>> +	int mod[3] = { 0, 0, 0 };
> 
> I'm probably missing something, but is the behavior of gcc wrt
> above initializers different on mips (it zeroes just fine on x86
> at least)? If yes, we'd probably need a cocci script to also check
> rest of the kernel given this is used in a number of places. Hm,
> could you elaborate?

This change is not necessary at all.

An empty initializer must clear the whole object to zero.

"theoretical" fix indeed... :-(
