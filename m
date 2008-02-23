From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 05/28] mm: allow PF_MEMALLOC from softirq context
Date: Sat, 23 Feb 2008 00:05:50 -0800
Message-ID: <20080223000550.00cfbfa5.akpm@linux-foundation.org>
References: <20080220144610.548202000@chello.nl>
	<20080220150305.905314000@chello.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	netdev@vger.kernel.org, trond.myklebust@fys.uio.no
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([207.189.120.13]:47940 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933010AbYBWIIx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Feb 2008 03:08:53 -0500
In-Reply-To: <20080220150305.905314000@chello.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 20 Feb 2008 15:46:15 +0100 Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:

> Allow PF_MEMALLOC to be set in softirq context. When running softirqs from
> a borrowed context save current->flags, ksoftirqd will have its own 
> task_struct.

The second sentence doesn't make sense.

> This is needed to allow network softirq packet processing to make use of
> PF_MEMALLOC.
>
> ...
>
> +#define tsk_restore_flags(p, pflags, mask) \
> +	do {	(p)->flags &= ~(mask); \
> +		(p)->flags |= ((pflags) & (mask)); } while (0)
> +

Does it need to be a macro?

If so, it really should cook up a temporary to avoid referencing p twice -
the children might be watching.
