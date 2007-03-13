From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [patch 4/4] tcp: statistics not read_mostly
Date: 13 Mar 2007 21:09:58 +0100
Message-ID: <p73wt1k9a7d.fsf@bingen.suse.de>
References: <20070312210817.485320783@linux-foundation.org>
	<20070312210907.925541692@linux-foundation.org>
	<20070312.141550.48806100.davem@davemloft.net>
	<20070312142647.57038d85@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1.suse.de ([195.135.220.2]:33609 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932332AbXCMTK7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Mar 2007 15:10:59 -0400
In-Reply-To: <20070312142647.57038d85@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger <shemminger@linux-foundation.org> writes:
> 
> /* 
>  * FIXME: On x86 and some other CPUs the split into user and softirq parts
>  * is not needed because addl $1,memory is atomic against interrupts (but 
>  * atomic_inc would be overkill because of the lock cycles). Wants new 
>  * nonlocked_atomic_inc() primitives -AK
>  */ 

That exists now as local_t.  And in fact the generic (non x86) local_t
is implemented in the same way as the current network statistics
(although I'm not convinced that's the best portable way to do this)

-Andi
