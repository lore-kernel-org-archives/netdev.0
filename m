From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 9758] New: net_device refcnt bug when
 NFQUEUEing bridged packets
Date: Wed, 16 Jan 2008 10:56:32 -0800
Message-ID: <20080116105632.2532812c@speedy>
References: <bug-9758-10286@http.bugzilla.kernel.org/>
	<20080115155655.d1a24eaf.akpm@linux-foundation.org>
	<478D8DF5.7080901@trash.net>
	<478D8F29.5040703@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:55479 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751419AbYAPS4d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Jan 2008 13:56:33 -0500
In-Reply-To: <478D8F29.5040703@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 16 Jan 2008 05:59:21 +0100
Patrick McHardy <kaber@trash.net> wrote:

> Patrick McHardy wrote:
> > Very nice catch, that explains quite a few bug reports about
> > refcnt leaks. Your patch looks correct and performs the copying
> > in the logically correct place, it would be nicer to keep this
> > crap limited to bridge netfilter however.
> > 
> > What should work is to perform the copying in br_netfilter.c
> > at the spots where phsyoutdev is assigned. As an optimization
> > we should be able to avoid the copying in most cases by
> > checking that the bridge info has a refcount above 1.
> > 
> > Could you test whether this patch also fixes the problem?
> 
> 
> That patch had a bug, we need to set the refcount of the
> new bridge info to 1 after performing the copy.
> 

This looks good, but you could use a structure assignment rather memcpy
(just a personal style preference because assignment is typed and memcpy
is not).
