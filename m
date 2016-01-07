From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v2 net-next] net: Implement fast csum_partial for x86_64
Date: Thu, 7 Jan 2016 02:52:04 +0100
Message-ID: <568DC4C4.2050908@stressinduktion.org>
References: <1452019261-449449-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kernel-team@fb.com, tglx@linutronix.de, mingo@redhat.com,
	hpa@zytor.com, x86@kernel.org
To: Tom Herbert <tom@herbertland.com>, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:48142 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751905AbcAGBwI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2016 20:52:08 -0500
Received: from compute2.internal (compute2.nyi.internal [10.202.2.42])
	by mailout.nyi.internal (Postfix) with ESMTP id 052F020AD2
	for <netdev@vger.kernel.org>; Wed,  6 Jan 2016 20:52:07 -0500 (EST)
In-Reply-To: <1452019261-449449-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Tom,

On 05.01.2016 19:41, Tom Herbert wrote:
> --- /dev/null
> +++ b/arch/x86/lib/csum-partial_64.S
> @@ -0,0 +1,147 @@
> +/* Copyright 2016 Tom Herbert <tom@herbertland.com>
> + *
> + * Checksum partial calculation
> + *
> + * __wsum csum_partial(const void *buff, int len, __wsum sum)
> + *
> + * Computes the checksum of a memory block at buff, length len,
> + * and adds in "sum" (32-bit)
> + *
> + * Returns a 32-bit number suitable for feeding into itself
> + * or csum_tcpudp_magic
> + *
> + * Register usage:
> + *   %rdi: argument 1, buff
> + *   %rsi: argument 2, length
> + *   %rdx: argument 3, add in value

I think you forgot to carry-add-in the %rdx register.

The assembly code replaces do_csum but not csum_partial.

Bye,
Hannes
