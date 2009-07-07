From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCHv5 2/2] memory barrier: adding smp_mb__after_lock
Date: Tue, 7 Jul 2009 16:34:16 +0200
Message-ID: <20090707143416.GB11704@redhat.com>
References: <20090703081445.GG2902@jolsa.lab.eng.brq.redhat.com> <20090703090606.GA3902@elte.hu> <4A4DCD54.1080908@gmail.com> <20090703092438.GE3902@elte.hu> <20090703095659.GA4518@jolsa.lab.eng.brq.redhat.com> <20090703102530.GD32128@elte.hu> <20090703111848.GA10267@jolsa.lab.eng.brq.redhat.com> <20090707101816.GA6619@jolsa.lab.eng.brq.redhat.com> <20090707134601.GB6619@jolsa.lab.eng.brq.redhat.com> <20090707140135.GA5506@Krystal>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Olsa <jolsa@redhat.com>, Ingo Molnar <mingo@elte.hu>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	fbl@redhat.com, nhorman@redhat.com, davem@redhat.com,
	htejun@gmail.com, jarkao2@gmail.com, davidel@xmailserver.org
To: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:53223 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758805AbZGGOhZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Jul 2009 10:37:25 -0400
Content-Disposition: inline
In-Reply-To: <20090707140135.GA5506@Krystal>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/07, Mathieu Desnoyers wrote:
>
> As with any optimization (and this is one that adds a semantic that will
> just grow the memory barrier/locking rule complexity), it should come
> with performance benchmarks showing real-life improvements.

Well, the same applies to smp_mb__xxx_atomic_yyy or smp_mb__before_clear_bit.

Imho the new helper is not worse, and it could be also used by
try_to_wake_up(), __pollwake(), insert_work() at least.

> Otherwise I'd recommend sticking to smp_mb() if this execution path is
> not that critical, or to move to RCU if it's _that_ critical.
>
> A valid argument would be if the data structures protected are so
> complex that RCU is out of question but still the few cycles saved by
> removing a memory barrier are really significant.

Not sure I understand how RCU can help,

> And even then, the
> proper solution would be more something like a
> __read_lock()+smp_mb+smp_mb+__read_unlock(), so we get the performance
> improvements on architectures other than x86 as well.

Hmm. could you explain what you mean?

Oleg.

