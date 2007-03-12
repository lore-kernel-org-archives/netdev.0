From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [patch 4/4] tcp: statistics not read_mostly
Date: Mon, 12 Mar 2007 14:26:47 -0700
Message-ID: <20070312142647.57038d85@freekitty>
References: <20070312210817.485320783@linux-foundation.org>
	<20070312210907.925541692@linux-foundation.org>
	<20070312.141550.48806100.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:43013 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752585AbXCLV0v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Mar 2007 17:26:51 -0400
In-Reply-To: <20070312.141550.48806100.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 12 Mar 2007 14:15:50 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <shemminger@linux-foundation.org>
> Date: Mon, 12 Mar 2007 14:08:21 -0700
> 
> > The TCP statistics shouldn't be located in the middle of the
> > read_mostly section surrounded by sysctl values.
> > Move EXPORT_SYMBOL next to data like other declarations near by.
> > 
> > Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
> 
> Stephen, they are pointers to the statistics, not the statistic
> counters themselves.  We're marking the _pointers_ as __read_mostly
> here.
> 
> When Eric originally submitted the change to add __read_mostly here I
> didn't understand it either.
> 
> Look at the definition of DEFINE_SNMP_STAT().

Okay, that's confusing. And maybe the comment suggests future work:



/* 
 * FIXME: On x86 and some other CPUs the split into user and softirq parts
 * is not needed because addl $1,memory is atomic against interrupts (but 
 * atomic_inc would be overkill because of the lock cycles). Wants new 
 * nonlocked_atomic_inc() primitives -AK
 */ 
-- 
Stephen Hemminger <shemminger@linux-foundation.org>
