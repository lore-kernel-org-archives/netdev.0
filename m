From: Edward Cree <ecree@solarflare.com>
Subject: Re: [PATCH net-next] bpf/verifier: track liveness for pruning
Date: Tue, 15 Aug 2017 13:53:24 +0100
Message-ID: <0de66302-95f9-feda-b537-1c515793be6a@solarflare.com>
References: <262cf31a-b70d-3dca-c687-8bcc77726011@solarflare.com>
 <5992E090.5040103@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        iovisor-dev <iovisor-dev@lists.iovisor.org>
To: Daniel Borkmann <daniel@iogearbox.net>, <davem@davemloft.net>,
        "Alexei Starovoitov" <alexei.starovoitov@gmail.com>,
        Alexei Starovoitov <ast@fb.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5992E090.5040103@iogearbox.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 15/08/17 12:52, Daniel Borkmann wrote:
> On 08/14/2017 07:55 PM, Edward Cree wrote:
>>       if (arg_type == ARG_ANYTHING) {
>>           if (is_pointer_value(env, regno)) {
>> @@ -1639,10 +1675,13 @@ static int check_call(struct bpf_verifier_env *env, int func_id, int insn_idx)
>>       }
>>
>>       /* reset caller saved regs */
>> -    for (i = 0; i < CALLER_SAVED_REGS; i++)
>> +    for (i = 0; i < CALLER_SAVED_REGS; i++) {
>>           mark_reg_not_init(regs, caller_saved[i]);
>> +        check_reg_arg(env, i, DST_OP_NO_MARK);
>
> Don't we need the same in check_ld_abs() since we treat it similar
> to a function call? 
Yes, I forgot about LD_ABS.  I'll fix it and spin a v2.
-Ed
