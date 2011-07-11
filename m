From: Matt Evans <matt@ozlabs.org>
Subject: Re: [RFC PATCH 1/1] BPF JIT for PPC64
Date: Mon, 11 Jul 2011 16:21:50 +1000
Message-ID: <4E1A967E.50908@ozlabs.org>
References: <4E04288F.4090201@ozlabs.org> <1308967114.3093.1379.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	linuxppc-dev <linuxppc-dev@lists.ozlabs.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:43904 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757160Ab1GKGV3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jul 2011 02:21:29 -0400
In-Reply-To: <1308967114.3093.1379.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 25/06/11 11:58, Ben Hutchings wrote:
> On Fri, 2011-06-24 at 16:02 +1000, Matt Evans wrote:
> [...]
>> +		case BPF_S_ALU_ADD_K: /* A += K; */
>> +			if (!K)
>> +				break;
>> +			if (K < 32768)
>> +				PPC_ADDI(r_A, r_A, K);
>> +			else
>> +				PPC_ADDI(r_A, r_A, IMM_L(K));
>> +				PPC_ADDIS(r_A, r_A, IMM_HA(K));
>> +			break;
> 
> Missing braces.
> 
>> +		case BPF_S_ALU_SUB_X: /* A -= X; */
>> +			ctx->seen |= SEEN_XREG;
>> +			PPC_SUB(r_A, r_A, r_X);
>> +			break;
>> +		case BPF_S_ALU_SUB_K: /* A -= K */
>> +			if (!K)
>> +				break;
>> +			if (K < 32768)
>> +				PPC_ADDI(r_A, r_A, -K);
>> +			else
>> +				PPC_ADDI(r_A, r_A, IMM_L(-K));
>> +				PPC_ADDIS(r_A, r_A, IMM_HA(-K));
>> +			break;
> [...]
> 
> Here as well.

Thanks, Ben -- oops! :)  Really, just the ADDISes need to be conditional, too.


Cheers,


Matt
