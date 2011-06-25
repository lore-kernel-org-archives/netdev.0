From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC PATCH 1/1] BPF JIT for PPC64
Date: Sat, 25 Jun 2011 02:58:34 +0100
Message-ID: <1308967114.3093.1379.camel@localhost>
References: <4E04288F.4090201@ozlabs.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	linuxppc-dev <linuxppc-dev@lists.ozlabs.org>
To: Matt Evans <matt@ozlabs.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:39562 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752011Ab1FYB6h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jun 2011 21:58:37 -0400
In-Reply-To: <4E04288F.4090201@ozlabs.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-06-24 at 16:02 +1000, Matt Evans wrote:
[...]
> +		case BPF_S_ALU_ADD_K: /* A += K; */
> +			if (!K)
> +				break;
> +			if (K < 32768)
> +				PPC_ADDI(r_A, r_A, K);
> +			else
> +				PPC_ADDI(r_A, r_A, IMM_L(K));
> +				PPC_ADDIS(r_A, r_A, IMM_HA(K));
> +			break;

Missing braces.

> +		case BPF_S_ALU_SUB_X: /* A -= X; */
> +			ctx->seen |= SEEN_XREG;
> +			PPC_SUB(r_A, r_A, r_X);
> +			break;
> +		case BPF_S_ALU_SUB_K: /* A -= K */
> +			if (!K)
> +				break;
> +			if (K < 32768)
> +				PPC_ADDI(r_A, r_A, -K);
> +			else
> +				PPC_ADDI(r_A, r_A, IMM_L(-K));
> +				PPC_ADDIS(r_A, r_A, IMM_HA(-K));
> +			break;
[...]

Here as well.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

