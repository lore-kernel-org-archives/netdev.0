From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: 2.6.27-rc4: icmp_sk() uses smp_processor_id() in preemptible code
Date: Thu, 21 Aug 2008 22:50:00 +1000
Message-ID: <E1KW9c0-0002Kp-00@gondolin.me.apana.org.au>
References: <20080821122040.GA2497@x200.localdomain>
Cc: den@openvz.org, dlezcano@fr.ibm.com, netdev@vger.kernel.org
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:60951 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753361AbYHUMuO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2008 08:50:14 -0400
In-Reply-To: <20080821122040.GA2497@x200.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

adobriyan@gmail.com wrote:
> Steps to reproduce:
> 
>        CONFIG_PREEMPT=y
>        CONFIG_DEBUG_PREEMPT=y
>        tracepath <something>
> 
> icmp6_sk() is similar (I haven't checked at runtime, though).
> 
> BUG: using smp_processor_id() in preemptible [00000000] code: tracepath/3205
> caller is icmp_sk+0x15/0x30
> Pid: 3205, comm: tracepath Not tainted 2.6.27-rc4 #1
> 
> Call Trace:
> [<ffffffff8031af14>] debug_smp_processor_id+0xe4/0xf0
> [<ffffffff80409405>] icmp_sk+0x15/0x30
> [<ffffffff8040a17b>] icmp_send+0x4b/0x3f0

Caused by:

commit 405666db84b984b68fc75794069f424c02e5796c
Author: Denis V. Lunev <den@openvz.org>
Date:   Fri Feb 29 11:16:46 2008 -0800

    [ICMP]: Pass proper ICMP socket into icmp(v6)_xmit_(un)lock.

We need to disable preemption (was provided by disabling BH) before
getting the per-cpu ICMP socket.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
