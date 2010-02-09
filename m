From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] dst: call cond_resched() in dst_gc_task()
Date: Mon, 8 Feb 2010 23:31:15 -0800
Message-ID: <20100208233115.456d847c.akpm@linux-foundation.org>
References: <1265639549.3048.33.camel@edumazet-laptop>
	<1265657560.4236.80.camel@edumazet-laptop>
	<20100208152606.91c55722.akpm@linux-foundation.org>
	<20100208.153406.123254133.davem@davemloft.net>
	<20100208153744.236158aa.akpm@linux-foundation.org>
	<20100208155053.4ad68484@nehalam>
	<1265695598.4236.95.camel@edumazet-laptop>
	<20100208223540.3cdabe44.akpm@linux-foundation.org>
	<1265700036.4236.120.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>, pstaszewski@itcare.pl,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:40296 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750836Ab0BIHbx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Feb 2010 02:31:53 -0500
In-Reply-To: <1265700036.4236.120.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 09 Feb 2010 08:20:36 +0100 Eric Dumazet <eric.dumazet@gmail.com> wrote:

> I suppose offlining a cpu migrates its works to another (online) cpu ?

Sort of, effectively.  The workqueue code runs all the pending works on
the to-be-offlined CPU and then it's done.

schedule_delayed_work() starts out with a timer, and the timer code
_does_ perform migration off the going-away CPU.
