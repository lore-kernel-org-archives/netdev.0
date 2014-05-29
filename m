From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH v1 net-next] net: filter: fix length calculation in BPF
 testsuite
Date: Thu, 29 May 2014 22:41:28 +0200
Message-ID: <53879B78.5050106@redhat.com>
References: <1401391757-27620-1-git-send-email-chema@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Alexei Starovoitov <ast@plumgrid.com>, netdev@vger.kernel.org
To: Chema Gonzalez <chema@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58036 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754147AbaE2Uln (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 May 2014 16:41:43 -0400
In-Reply-To: <1401391757-27620-1-git-send-email-chema@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/29/2014 09:29 PM, Chema Gonzalez wrote:
> The current probe_filter_length() (the function that calculates the
> length of a test BPF filter) behavior is to declare the end of the
> filter as soon as it finds {0, *, *, 0}. This is actually a valid
> insn ("ld #0"), so any filter with includes "BPF_STMT(BPF_LD | BPF_IMM, 0)"
> fails (its length is cut short).
>
> We are changing probe_filter_length() so as to start from the end, and
> declare the end of the filter as the first instruction which is not
> {0, *, *, 0}. This solution produces a simpler patch than the
> alternative of using an explicit end-of-filter mark. It is technically
> incorrect if your filter ends up with "ld #0", but that should not
> happen anyway.
>
> We also add a new test (LD_IMM_0) that includes ld #0 (does not work
> without this patch).
>
> Signed-off-by: Chema Gonzalez <chema@google.com>

Looks good to me, thanks a lot Chema!

Acked-by: Daniel Borkmann <dborkman@redhat.com>

> +	for (len = MAX_INSNS-1; len > 0; --len)
> +		if (fp[len].code != 0 || fp[len].k != 0)
> +			break;
>
> -	return len;
> +	return len+1;

Nit: would be great to have a whitespace between MAX_INSNS-1 and len+1 but
that shouldn't matter that much, perhaps.
