From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/1] net: convert %p usage to %pK
Date: Tue, 24 May 2011 01:13:30 -0400 (EDT)
Message-ID: <20110524.011330.1077020828173889583.davem@davemloft.net>
References: <201105232217.p4NMHZiC015498@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, drosenberg@vsecurity.com,
	a.p.zijlstra@chello.nl, eparis@parisplace.org,
	eric.dumazet@gmail.com, eugeneteo@kernel.org, jmorris@namei.org,
	kees.cook@canonical.com, mingo@elte.hu, tgraf@infradead.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:47035 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751469Ab1EXFRW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 May 2011 01:17:22 -0400
In-Reply-To: <201105232217.p4NMHZiC015498@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: akpm@linux-foundation.org
Date: Mon, 23 May 2011 15:17:35 -0700

> From: Dan Rosenberg <drosenberg@vsecurity.com>
> 
> The %pK format specifier is designed to hide exposed kernel pointers,
> specifically via /proc interfaces.  Exposing these pointers provides an
> easy target for kernel write vulnerabilities, since they reveal the
> locations of writable structures containing easily triggerable function
> pointers.  The behavior of %pK depends on the kptr_restrict sysctl.
> 
> If kptr_restrict is set to 0, no deviation from the standard %p behavior
> occurs.  If kptr_restrict is set to 1, the default, if the current user
> (intended to be a reader via seq_printf(), etc.) does not have CAP_SYSLOG
> (currently in the LSM tree), kernel pointers using %pK are printed as 0's.
>  If kptr_restrict is set to 2, kernel pointers using %pK are printed as
> 0's regardless of privileges.  Replacing with 0's was chosen over the
> default "(null)", which cannot be parsed by userland %p, which expects
> "(nil)".
> 
> The supporting code for kptr_restrict and %pK are currently in the -mm
> tree.  This patch converts users of %p in net/ to %pK.  Cases of printing
> pointers to the syslog are not covered, since this would eliminate useful
> information for postmortem debugging and the reading of the syslog is
> already optionally protected by the dmesg_restrict sysctl.
> 
> Signed-off-by: Dan Rosenberg <drosenberg@vsecurity.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Applied.
