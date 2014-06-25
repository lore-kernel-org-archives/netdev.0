From: Markos Chandras <Markos.Chandras@imgtec.com>
Subject: Re: [PATCH 16/17] MIPS: bpf: Use 32 or 64-bit load instruction to
 load an address to register
Date: Wed, 25 Jun 2014 09:18:48 +0100
Message-ID: <53AA85E8.5090403@imgtec.com>
References: <1403516340-22997-1-git-send-email-markos.chandras@imgtec.com> <1403516340-22997-17-git-send-email-markos.chandras@imgtec.com> <20140623202437.GD2200@pburton-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <linux-mips@linux-mips.org>,
	"David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	Alexei Starovoitov <ast@plumgrid.com>, <netdev@vger.kernel.org>
To: Paul Burton <paul.burton@imgtec.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailapp01.imgtec.com ([195.59.15.196]:42917 "EHLO
	mailapp01.imgtec.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754777AbaFYISv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jun 2014 04:18:51 -0400
In-Reply-To: <20140623202437.GD2200@pburton-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/23/2014 09:24 PM, Paul Burton wrote:
> On Mon, Jun 23, 2014 at 10:38:59AM +0100, Markos Chandras wrote:
>> diff --git a/arch/mips/net/bpf_jit.c b/arch/mips/net/bpf_jit.c
>> index 4920e0fd05ee..d8dba7b523a5 100644
>> --- a/arch/mips/net/bpf_jit.c
>> +++ b/arch/mips/net/bpf_jit.c
>> @@ -447,6 +447,17 @@ static inline void emit_wsbh(unsigned int dst, unsigned int src,
>>  	emit_instr(ctx, wsbh, dst, src);
>>  }
>>  
>> +/* load address to register */
>> +static inline void emit_load_addr(unsigned int dst, unsigned int src,
>> +				     int imm, struct jit_ctx *ctx)
> 
> (I originally sent this in reply to your internal posting, but assume you
> missed it or it got eaten somewhere along the way.)
> 
> The name emit_load_addr & comment "load address to register" makes this
> sound like an equivalent of the "la" pseudo instruction, but it appears
> to really emit a pointer sized load? How about emit_load_ptr or something
> instead, and similarly s/address/pointer/ in the comment?
> 
Hi Paul,

I suppose I could do that. I will send a v2

>> +{
>> +	/* src contains the base addr of the 32/64-pointer */
>> +	if (config_enabled(CONFIG_64BIT))
>> +		emit_instr(ctx, ld, dst, imm, src);
>> +	else
>> +		emit_instr(ctx, lw, dst, imm, src);
> 
> Is there some way you could make use of the UASM_i_LW macro (note the
> capitalisation) instead of the if statement here?
> 

Not right now. I use config_enabled(CONFIG_64BIT) everywhere in that
file to emit 32-bit or 64-bit instructions. So I will look into
switching to the USAM_i_* macros when i submit the remaining fixes
probably for 3.17.

-- 
markos
