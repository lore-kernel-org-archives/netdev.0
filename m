From: Jeremy Fitzhardinge <jeremy@goop.org>
Subject: Re: [PATCH] x86: percpu_to_op() misses memory and flags clobbers
Date: Wed, 01 Apr 2009 11:07:29 -0700
Message-ID: <49D3AD61.5090206@goop.org>
References: <49D32212.80607@cosmosbay.com> <49D32DC2.9010003@goop.org> <49D33E80.70802@cosmosbay.com> <20090401161218.GB3859@elte.hu> <49D3A0C2.9000403@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@elte.hu>, Tejun Heo <htejun@gmail.com>,
	linux kernel <linux-kernel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Joe Perches <joe@perches.com>,
	Rusty Russell <rusty@rustcorp.com.au>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw.goop.org ([64.81.55.164]:37276 "EHLO mail.goop.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933293AbZDASHi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Apr 2009 14:07:38 -0400
In-Reply-To: <49D3A0C2.9000403@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> +#define percpu_inc(var)		percpu_to_op0("inc", per_cpu__##var)
> +#define percpu_dec(var)		percpu_to_op0("dec", per_cpu__##var)
>   

There's probably not a lot of value in this.  The Intel and AMD 
optimisation guides tend to deprecate inc/dec in favour of using 
add/sub, because the former can cause pipeline stalls due to its partial 
flags update.

    J
