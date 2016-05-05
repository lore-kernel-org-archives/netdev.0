From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH nf-next 0/9] netfilter: remove per-netns conntrack
 tables, part 1
Date: Thu, 5 May 2016 13:54:51 +0200
Message-ID: <20160505115451.GB10879@salvia>
References: <1461863628-23350-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:59618 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753526AbcEELzA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 May 2016 07:55:00 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id 8C97C4B9E9
	for <netdev@vger.kernel.org>; Thu,  5 May 2016 13:54:58 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 7CB461B306E
	for <netdev@vger.kernel.org>; Thu,  5 May 2016 13:54:58 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 58C611B306E
	for <netdev@vger.kernel.org>; Thu,  5 May 2016 13:54:56 +0200 (CEST)
Content-Disposition: inline
In-Reply-To: <1461863628-23350-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 28, 2016 at 07:13:39PM +0200, Florian Westphal wrote:
> [ CCing netdev so netns folks can have a look too ]
> 
> This patch series removes the per-netns connection tracking tables.
> All conntrack objects are then stored in one global global table.
> 
> This avoids the infamous 'vmalloc' when lots of namespaces are used:
> We no longer allocate a new conntrack table for each namespace (with 64k
> size this saves 512kb of memory per netns).
> 
> - net namespace address is made part of conntrack hash, to spread
>   conntracks over entire table even if netns has overlapping ip addresses.
> - lookup and iterators net_eq() to skip conntracks living in a different
>   namespace.
> 
> Only the main conntrack table is converted here:
> NAT bysrc and expectation hashes are still per namespace (will be unified
> in a followup series).  Also, this retains the per-namespace kmem cache
> for the conntrack objects.  This will also be resolved in a followup series.

Series applied, thanks Florian.
