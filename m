From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH] net: Saner thash_entries default with much memory
Date: Fri, 26 Oct 2007 17:34:17 +0200
Message-ID: <20071026153416.GA23491@bingen.suse.de>
References: <200710261721.32019.jdelvare@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Andi Kleen <ak@suse.de>
To: Jean Delvare <jdelvare@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.suse.de ([195.135.220.15]:46229 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763029AbXJZPeS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Oct 2007 11:34:18 -0400
Received: from Relay2.suse.de (mail2.suse.de [195.135.221.8])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx2.suse.de (Postfix) with ESMTP id A099122B25
	for <netdev@vger.kernel.org>; Fri, 26 Oct 2007 17:34:17 +0200 (CEST)
Content-Disposition: inline
In-Reply-To: <200710261721.32019.jdelvare@suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 26, 2007 at 05:21:31PM +0200, Jean Delvare wrote:
> I know that /proc/net/tcp is
> deprecated in favor of tcp_diag, however at the moment netstat only
> knows of the former.

Even tcp_diag will be slow when all slots are dumped. It's a fundamental
problem of the data structure. /proc has slightly higher constant
factor overhead, that's all.

Also there are some tricks to make it a little faster (e.g.
the old patches to not take the lock for empty buckets) but again
it's only just patching constant factors, not the fundamental
scaling issue.

> I propose 2 millions of entries as the arbitrary high limit. This

It's probably still far too large.

-Andi

