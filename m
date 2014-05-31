From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH v2 net-next] net: filter: fix length calculation in BPF
 testsuite
Date: Sat, 31 May 2014 21:21:50 +0200
Message-ID: <538A2BCE.7070805@redhat.com>
References: <53879B78.5050106@redhat.com> <1401470112-3933-1-git-send-email-chema@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Alexei Starovoitov <ast@plumgrid.com>, netdev@vger.kernel.org
To: Chema Gonzalez <chema@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47855 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751577AbaEaTWA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 31 May 2014 15:22:00 -0400
In-Reply-To: <1401470112-3933-1-git-send-email-chema@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/30/2014 07:15 PM, Chema Gonzalez wrote:
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

Thanks (sorry for the delay as I'm currently on travel).

Acked-by: Daniel Borkmann <dborkman@redhat.com>
