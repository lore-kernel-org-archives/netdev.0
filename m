From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [Xen-devel] [PATCH v4] xen/grant-table: Avoid m2p_override during
 mapping
Date: Wed, 22 Jan 2014 10:58:00 +0000
Message-ID: <52DFA438.6050103@citrix.com>
References: <1390335755-29328-1-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <ian.campbell@citrix.com>, <wei.liu2@citrix.com>,
	<xen-devel@lists.xenproject.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <jonathan.davies@citrix.com>,
	Stefano Stabellini <stefano.stabellini@eu.citrix.com>
To: Zoltan Kiss <zoltan.kiss@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:1098 "EHLO SMTP02.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751773AbaAVK6F (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jan 2014 05:58:05 -0500
In-Reply-To: <1390335755-29328-1-git-send-email-zoltan.kiss@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 21/01/14 20:22, Zoltan Kiss wrote:
> The grant mapping API does m2p_override unnecessarily: only gntdev needs it,
> for blkback and future netback patches it just cause a lock contention, as
> those pages never go to userspace. Therefore this series does the following:
> - the original functions were renamed to __gnttab_[un]map_refs, with a new
>   parameter m2p_override
> - based on m2p_override either they follow the original behaviour, or just set
>   the private flag and call set_phys_to_machine
> - gnttab_[un]map_refs are now a wrapper to call __gnttab_[un]map_refs with
>   m2p_override false
> - a new function gnttab_[un]map_refs_userspace provides the old behaviour
> 
> v2:
> - move the storing of the old mfn in page->index to gnttab_map_refs
> - move the function header update to a separate patch
> 
> v3:
> - a new approach to retain old behaviour where it needed
> - squash the patches into one
> 
> v4:
> - move out the common bits from m2p* functions, and pass pfn/mfn as parameter
> - clear page->private before doing anything with the page, so m2p_find_override
>   won't race with this

I would prune this version information out of the commit message.

> Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>
> Suggested-by: David Vrabel <david.vrabel@citrix.com>

Reviewed-by: David Vrabel <david.vrabel@citrix.com>

But I think this needs Stefano's ack.

It would be useful to get this into 3.14 if possible.

David
