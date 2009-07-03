From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCHv5 2/2] memory barrier: adding smp_mb__after_lock
Date: Fri, 3 Jul 2009 11:30:27 +0000
Message-ID: <20090703113027.GC4847@ff.dom.local>
References: <20090703081219.GE2902@jolsa.lab.eng.brq.redhat.com> <20090703081445.GG2902@jolsa.lab.eng.brq.redhat.com> <20090703090606.GA3902@elte.hu> <4A4DCD54.1080908@gmail.com> <20090703092438.GE3902@elte.hu> <20090703095659.GA4518@jolsa.lab.eng.brq.redhat.com> <20090703102530.GD32128@elte.hu> <20090703111848.GA10267@jolsa.lab.eng.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ingo Molnar <mingo@elte.hu>, Eric Dumazet <eric.dumazet@gmail.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	fbl@redhat.com, nhorman@redhat.com, davem@redhat.com,
	htejun@gmail.com, oleg@redhat.com, davidel@xmailserver.org
To: Jiri Olsa <jolsa@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f207.google.com ([209.85.218.207]:59811 "EHLO
	mail-bw0-f207.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752916AbZGCLac (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jul 2009 07:30:32 -0400
Content-Disposition: inline
In-Reply-To: <20090703111848.GA10267@jolsa.lab.eng.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 03, 2009 at 01:18:48PM +0200, Jiri Olsa wrote:
...
> diff --git a/arch/x86/include/asm/spinlock.h b/arch/x86/include/asm/spinlock.h
> index b7e5db8..4e77853 100644
> --- a/arch/x86/include/asm/spinlock.h
> +++ b/arch/x86/include/asm/spinlock.h
...
> @@ -1271,6 +1271,9 @@ static inline int sk_has_allocations(const struct sock *sk)
>   * in its cache, and so does the tp->rcv_nxt update on CPU2 side.  The CPU1
>   * could then endup calling schedule and sleep forever if there are no more
>   * data on the socket.
> + *
> + * The sk_has_helper is always called right after a call to read_lock, so we
Btw.:
- * The sk_has_helper is always called right after a call to read_lock, so we
+ * The sk_has_sleeper is always called right after a call to read_lock, so we

Jarek P.
