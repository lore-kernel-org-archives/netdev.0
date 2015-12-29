From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] openvswitch: Fix template leak in error cases.
Date: Tue, 29 Dec 2015 15:28:22 -0500 (EST)
Message-ID: <20151229.152822.353618428420139342.davem@davemloft.net>
References: <1450910367-61953-1-git-send-email-joe@ovn.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	pshelar@nicira.com
To: joe@ovn.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59980 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753704AbbL2U2X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Dec 2015 15:28:23 -0500
In-Reply-To: <1450910367-61953-1-git-send-email-joe@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Stringer <joe@ovn.org>
Date: Wed, 23 Dec 2015 14:39:27 -0800

> Commit 5b48bb8506c5 ("openvswitch: Fix helper reference leak") fixed a
> reference leak on helper objects, but inadvertently introduced a leak on
> the ct template.
> 
> Previously, ct_info.ct->general.use was initialized to 0 by
> nf_ct_tmpl_alloc() and only incremented when ovs_ct_copy_action()
> returned successful. If an error occurred while adding the helper or
> adding the action to the actions buffer, the __ovs_ct_free_action()
> cleanup would use nf_ct_put() to free the entry; However, this relies on
> atomic_dec_and_test(ct_info.ct->general.use). This reference must be
> incremented first, or nf_ct_put() will never free it.
> 
> Fix the issue by acquiring a reference to the template immediately after
> allocation.
> 
> Fixes: cae3a2627520 ("openvswitch: Allow attaching helpers to ct action")
> Fixes: 5b48bb8506c5 ("openvswitch: Fix helper reference leak")
> Signed-off-by: Joe Stringer <joe@ovn.org>

Looks good, applied, thanks Joe.
