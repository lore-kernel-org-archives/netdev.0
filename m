From: Denis Kirjanov <kda@linux-powerpc.org>
Subject: Re: [PATCH] mips: bpf: Fix broken BPF_MOD
Date: Mon, 1 Dec 2014 14:37:41 +0400
Message-ID: <CAOJe8K09mkRsg7Lm9znb-7wpyOAaGG7sZRQA3y=FT-RLX=eX8g@mail.gmail.com>
References: <1417427822-12729-1-git-send-email-kda@linux-powerpc.org>
	<547C3F2F.3070708@imgtec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: stable@vger.kernel.org,
	Markos Chandras <Markos.Chandras@imgtec.com>
To: Network Development <netdev@vger.kernel.org>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <547C3F2F.3070708@imgtec.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/1/14, Markos Chandras <Markos.Chandras@imgtec.com> wrote:
> On 12/01/2014 09:57 AM, Denis Kirjanov wrote:
>> Remove optimize_div() from BPF_MOD | BPF_K case
>> since we don't know the dividend and fix the
>> emit_mod() by reading the mod operation result from HI register
>>
>> Signed-off-by: Denis Kirjanov <kda@linux-powerpc.org>
>> ---
>>  arch/mips/net/bpf_jit.c |    4 ++--
>>  1 file changed, 2 insertions(+), 2 deletions(-)
>>
>> diff --git a/arch/mips/net/bpf_jit.c b/arch/mips/net/bpf_jit.c
>> index 9b55143..9fd6834 100644
>> --- a/arch/mips/net/bpf_jit.c
>> +++ b/arch/mips/net/bpf_jit.c
>> @@ -426,7 +426,7 @@ static inline void emit_mod(unsigned int dst, unsigned
>> int src,
>>  		u32 *p = &ctx->target[ctx->idx];
>>  		uasm_i_divu(&p, dst, src);
>>  		p = &ctx->target[ctx->idx + 1];
>> -		uasm_i_mflo(&p, dst);
>> +		uasm_i_mfhi(&p, dst);
>
> That looks correct.
>
>>  	}
>>  	ctx->idx += 2; /* 2 insts */
>>  }
>> @@ -971,7 +971,7 @@ load_ind:
>>  			break;
>>  		case BPF_ALU | BPF_MOD | BPF_K:
>>  			/* A %= k */
>> -			if (k == 1 || optimize_div(&k)) {
>> +			if (k == 1) {
>>  				ctx->flags |= SEEN_A;
>>  				emit_jit_reg_move(r_A, r_zero, ctx);
>>  			} else {
>>
>
> That looks correct too. Thanks for fixing these.
>
> Can you also CC stable for inclusion in >=3.16?
>
> Reviewed-by: Markos Chandras <markos.chandras@imgtec.com>
Cc: stable@vger.kernel.org
> --
> markos
>
