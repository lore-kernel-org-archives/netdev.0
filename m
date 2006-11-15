From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fix up sysctl_tcp_mem initialization
Date: Tue, 14 Nov 2006 20:31:18 -0800 (PST)
Message-ID: <20061114.203118.35665382.davem@davemloft.net>
References: <455A20BD.6010508@psc.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:16612
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S966585AbWKOEbQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Nov 2006 23:31:16 -0500
To: jheffner@psc.edu
In-Reply-To: <455A20BD.6010508@psc.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: John Heffner <jheffner@psc.edu>
Date: Tue, 14 Nov 2006 15:02:05 -0500

> The initial values of sysctl_tcp_mem are sometimes greater than the 
> total memory in the system (particularly on SMP systems).  This patch 
> ensures that tcp_mem[2] is always <= 3/4 nr_kernel_pages.

This is a genuine bug fix so I'll apply this, thanks for taking
care of these corner-case bugs in TCP sizing Jeff.

> However, I wonder if we want to set this differently than the way this 
> patch does it.  Depending on how far off the memory size is from a power 
> of two (exactly equal to a power of two is the worst case), and if total 
> memory <128M, it can be substantially less than 3/4.

Longer term, yes, probably a better way exists.

So you concern is that when we round to a power of 2 like we do
now, we often mis-shoot?

