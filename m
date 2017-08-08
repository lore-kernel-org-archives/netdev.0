From: James Hogan <james.hogan@imgtec.com>
Subject: Re: [RFC PATCH 2/2] bpf: Initialise mod[] in bpf_trace_printk
Date: Tue, 08 Aug 2017 22:20:05 +0100
Message-ID: <650EB3B0-1101-4624-905A-E68D2EC5920F@imgtec.com>
References: <20170807222514.24292-1-james.hogan@imgtec.com> <20170807222514.24292-3-james.hogan@imgtec.com> <59897A7C.10009@iogearbox.net> <20170808.094857.245786887664041622.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: ast@kernel.org, linux-kernel@vger.kernel.org, rostedt@goodmis.org,
        mingo@redhat.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, daniel@iogearbox.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170808.094857.245786887664041622.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 8 August 2017 17:48:57 BST, David Miller <davem@davemloft=2Enet> wrote:
>From: Daniel Borkmann <daniel@iogearbox=2Enet>
>Date: Tue, 08 Aug 2017 10:46:52 +0200
>
>> On 08/08/2017 12:25 AM, James Hogan wrote:
>>> In bpf_trace_printk(), the elements in mod[] are left uninitialised,
>>> but
>>> they are then incremented to track the width of the formats=2E Zero
>>> initialise the array just in case the memory contains non-zero
>values
>>> on
>>> entry=2E
>>>
>>> Fixes: 9c959c863f82 ("tracing: Allow BPF programs to call
>>> bpf_trace_printk()")
>>> Signed-off-by: James Hogan <james=2Ehogan@imgtec=2Ecom>
>>> Cc: Alexei Starovoitov <ast@kernel=2Eorg>
>>> Cc: Daniel Borkmann <daniel@iogearbox=2Enet>
>>> Cc: Steven Rostedt <rostedt@goodmis=2Eorg>
>>> Cc: Ingo Molnar <mingo@redhat=2Ecom>
>>> Cc: netdev@vger=2Ekernel=2Eorg
>>> ---
>>> When I checked (on MIPS32), the elements tended to have the value
>zero
>>> anyway (does BPF zero the stack or something clever?), so this is a
>>> purely theoretical fix=2E
>>> ---
>>>   kernel/trace/bpf_trace=2Ec | 2 +-
>>>   1 file changed, 1 insertion(+), 1 deletion(-)
>>>
>>> diff --git a/kernel/trace/bpf_trace=2Ec b/kernel/trace/bpf_trace=2Ec
>>> index 32dcbe1b48f2=2E=2E86a52857d941 100644
>>> --- a/kernel/trace/bpf_trace=2Ec
>>> +++ b/kernel/trace/bpf_trace=2Ec
>>> @@ -129,7 +129,7 @@ BPF_CALL_5(bpf_trace_printk, char *, fmt, u32,
>>> fmt_size, u64, arg1,
>>>   	   u64, arg2, u64, arg3)
>>>   {
>>>   	bool str_seen =3D false;
>>> -	int mod[3] =3D {};
>>> +	int mod[3] =3D { 0, 0, 0 };
>>=20
>> I'm probably missing something, but is the behavior of gcc wrt
>> above initializers different on mips (it zeroes just fine on x86
>> at least)? If yes, we'd probably need a cocci script to also check
>> rest of the kernel given this is used in a number of places=2E Hm,
>> could you elaborate?
>
>This change is not necessary at all=2E
>
>An empty initializer must clear the whole object to zero=2E
>
>"theoretical" fix indeed=2E=2E=2E :-(

cool, i hadn't realised unmentioned elements in an initialiser are always =
zeroed, even when non-global/static, so had interpreted the whole array as =
uninitialised=2E learn something new every day :-) sorry for the noise=2E

cheers
James
