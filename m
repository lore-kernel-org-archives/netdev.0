From: Tejun Heo <htejun@gmail.com>
Subject: Re: [RFC] percpu: convert SNMP mibs to new infra
Date: Thu, 02 Apr 2009 09:13:23 +0900
Message-ID: <49D40323.2020406@gmail.com>
References: <49D32212.80607@cosmosbay.com> <49D32DC2.9010003@goop.org> <49D33E80.70802@cosmosbay.com> <20090401161218.GB3859@elte.hu> <49D3A0C2.9000403@cosmosbay.com> <49D3B61F.8010507@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@elte.hu>, Jeremy Fitzhardinge <jeremy@goop.org>,
	linux kernel <linux-kernel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Joe Perches <joe@perches.com>,
	Rusty Russell <rusty@rustcorp.com.au>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ti-out-0910.google.com ([209.85.142.184]:17499 "EHLO
	ti-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756693AbZDBANb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2009 20:13:31 -0400
In-Reply-To: <49D3B61F.8010507@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello, Eric, Ingo.

Eric Dumazet wrote:
> diff --git a/arch/x86/include/asm/percpu.h b/arch/x86/include/asm/percpu.h
> index aee103b..6b82f6b 100644
> --- a/arch/x86/include/asm/percpu.h
> +++ b/arch/x86/include/asm/percpu.h
> @@ -135,6 +135,9 @@ do {							\
>  #define percpu_read(var)	percpu_from_op("mov", per_cpu__##var)
>  #define percpu_write(var, val)	percpu_to_op("mov", per_cpu__##var, val)
>  #define percpu_add(var, val)	percpu_to_op("add", per_cpu__##var, val)
> +#define indir_percpu_add(var, val)	percpu_to_op("add", *(var), val)
> +#define indir_percpu_inc(var)       percpu_to_op("add", *(var), 1)
> +#define indir_percpu_dec(var)       percpu_to_op("add", *(var), -1)
>  #define percpu_sub(var, val)	percpu_to_op("sub", per_cpu__##var, val)
>  #define percpu_and(var, val)	percpu_to_op("and", per_cpu__##var, val)
>  #define percpu_or(var, val)	percpu_to_op("or", per_cpu__##var, val)

The final goal is to unify static and dynamic accesses but we aren't
there yet, so, for the time being, we'll need some interim solutions.
I would prefer percpu_ptr_add() tho.

Thanks.

-- 
tejun
