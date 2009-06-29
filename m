From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] net: fix race in the receive/select
Date: Mon, 29 Jun 2009 19:29:38 +0200
Message-ID: <20090629172938.GE6760@one.firstfloor.org>
References: <20090625122545.GA3625@jolsa.lab.eng.brq.redhat.com> <87eit3l7y6.fsf@basil.nowhere.org> <4A48F30D.8000803@acm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>, Jiri Olsa <jolsa@redhat.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	fbl@redhat.com, nhorman@redhat.com, davem@redhat.com,
	oleg@redhat.com, eric.dumazet@gmail.com
To: Zan Lynx <zlynx@acm.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:60537 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752478AbZF2R3i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Jun 2009 13:29:38 -0400
Content-Disposition: inline
In-Reply-To: <4A48F30D.8000803@acm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 29, 2009 at 10:59:57AM -0600, Zan Lynx wrote:
> Andi Kleen wrote:
> >At least on x86 I can't see how it happens. mb() is only a compile
> >time barrier and the compiler doesn't optimize over indirect callbacks
> >like __pollwait() anyways.
> 
> Just a note about this. That used to be true, that GCC didn't optimize 
> indirect calls. However, see -findirect-inlining in GCC 4.4.

I am aware of that, but ...

> 
> I am not saying that it applies here, but it is something to remember.

... it doesn't apply here because it works only for a few very simple
cases that don't apply for this code. Besides the kernel builds with -O2,
which only inlines functions called once or very small functions, which
also rules this out.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.
