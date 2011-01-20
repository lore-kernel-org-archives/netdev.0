From: Vlad Dogaru <ddvlad@rosedu.org>
Subject: Re: [PATCH] rtnetlink: fix link attribute validation with
 IFLA_GROUP
Date: Thu, 20 Jan 2011 18:09:10 +0200
Message-ID: <20110120160909.GC12415@cormyr>
References: <4D3831FA.2010806@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NetDev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [141.85.37.41] ([141.85.37.41]:59721 "EHLO swarm.cs.pub.ro"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751103Ab1AUHZw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Jan 2011 02:25:52 -0500
Content-Disposition: inline
In-Reply-To: <4D3831FA.2010806@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 20, 2011 at 02:00:42PM +0100, Patrick McHardy wrote:
> Fix a few semantic problems with the new IFLA_GROUP attribute.
> 
> Vlad, could you please give this is a try to see whether it
> still behaves as expected?

> commit e4b31d565a45e06ed2e51a005f5c00ff1d00725c
> Author: Patrick McHardy <kaber@trash.net>
> Date:   Thu Jan 20 13:55:25 2011 +0100
> 
>     rtnetlink: fix link attribute validation with IFLA_GROUP
>     
>     rtnl_group_changelink() is invoked by rtnl_newlink() before the link
>     attributes have been validated. Additionally the group changes are
>     performed even if NLM_F_CREATE is specified and a new link is
>     created, while more reasonable semantics would be to set the group
>     value on the newly created link.
>     
>     Fix both problems by moving the rtnl_group_changelink() invocation
>     down to the handling of non-existant links without NLM_F_CREATE()
>     and add a dev_set_group() call to rtnl_create_link().
>     
>     Signed-off-by: Patrick McHardy <kaber@trash.net>

Acked-by: Vlad Dogaru <ddvlad@rosedu.org>

This looks OK and behaves as before. Thanks for taking the time to look
through it, the new semantics do seem saner.

There is a slight difference, though: in the (yet unapplied) iproute2
patch, ifi_index is set to -1 and kernel space checks that it is <= 0;
your patch checks for == 0. I will update the iproute2 patches with
setting ifi_index to 0 (and other changes) and resubmit them.
