From: David Miller <davem@davemloft.net>
Subject: Re: [1/4] kevent: core files.
Date: Fri, 23 Jun 2006 15:12:06 -0700 (PDT)
Message-ID: <20060623.151206.125894969.davem@davemloft.net>
References: <20060623203114.GD14126@kvack.org>
	<20060623.135423.115910361.davem@davemloft.net>
	<20060623215314.GG14126@kvack.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johnpol@2ka.mipt.ru, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:14012
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1752115AbWFWWMF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Jun 2006 18:12:05 -0400
To: bcrl@kvack.org
In-Reply-To: <20060623215314.GG14126@kvack.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Benjamin LaHaise <bcrl@kvack.org>
Date: Fri, 23 Jun 2006 17:53:14 -0400

> The effect of doing all processing in user context creates issues 
> with delayed acks (due to context switching to other tasks in the system), 

The Linux TCP stack does this today.

Full TCP input protocol processing is done in the user process
context.

What you are not understanding is that process scheduling helps TCP,
it does not hinder it.  If the system is loaded, we want the senders
to pace themselves to the rate at which the kernel can schedule the
abundance of receiver work it has.  And this happens naturally when
the TCP protocol input processing operates in process context.

Your fear of cpu overcommit in interrupt handlers is also heavily
flawed.  Net channels do a socket demux, and a queue entail plus
ring a doorbell if necessary, nothing more.
