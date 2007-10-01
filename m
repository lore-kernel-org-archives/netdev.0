From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 05/10] Add divisor.
Date: Mon, 01 Oct 2007 15:38:07 +0200
Message-ID: <4700F83F.9020300@trash.net>
References: <1191019977201-git-send-email-bugfood-ml@fatooh.org> <11910199772834-git-send-email-bugfood-ml@fatooh.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Corey Hickey <bugfood-ml@fatooh.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:33035 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751691AbXJANic (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Oct 2007 09:38:32 -0400
In-Reply-To: <11910199772834-git-send-email-bugfood-ml@fatooh.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Corey Hickey wrote:
> Make hash divisor user-configurable.
> 

> @@ -120,7 +121,7 @@ static __inline__ unsigned sfq_fold_hash(struct sfq_sched_data *q, u32 h, u32 h1
>  	/* Have we any rotation primitives? If not, WHY? */
>  	h ^= (h1<<pert) ^ (h1>>(0x1F - pert));
>  	h ^= h>>10;
> -	return h & 0x3FF;
> +	return h & (q->hash_divisor-1);


This assumes that hash_divisor is a power of two, but this is
not enforced anywhere.
