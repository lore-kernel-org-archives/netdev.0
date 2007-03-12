From: David Miller <davem@davemloft.net>
Subject: Re: [patch 4/4] tcp: statistics not read_mostly
Date: Mon, 12 Mar 2007 14:33:06 -0700 (PDT)
Message-ID: <20070312.143306.18307677.davem@davemloft.net>
References: <20070312210907.925541692@linux-foundation.org>
	<20070312.141550.48806100.davem@davemloft.net>
	<20070312142647.57038d85@freekitty>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59664
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S932424AbXCLVdH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Mar 2007 17:33:07 -0400
In-Reply-To: <20070312142647.57038d85@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Mon, 12 Mar 2007 14:26:47 -0700

> On Mon, 12 Mar 2007 14:15:50 -0700 (PDT)
> David Miller <davem@davemloft.net> wrote:
> 
> > Look at the definition of DEFINE_SNMP_STAT().
> 
> Okay, that's confusing. And maybe the comment suggests future work:

Indeed.

> /* 
>  * FIXME: On x86 and some other CPUs the split into user and softirq parts
>  * is not needed because addl $1,memory is atomic against interrupts (but 
>  * atomic_inc would be overkill because of the lock cycles). Wants new 
>  * nonlocked_atomic_inc() primitives -AK
>  */ 

Yep.  And another interesting case are straight loads and stores of
per-cpu values on platforms that have a PDA'ish thing like x86_64 and
sparc64.  The latter has the per-cpu base in a register so in several
cases the usual preemption protection simply does not matter and we
could optimize them away.
