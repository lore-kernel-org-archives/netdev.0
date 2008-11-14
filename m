From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] scm: fix scm_fp_list->list initialization made in
 wrong place
Date: Fri, 14 Nov 2008 14:52:18 -0800 (PST)
Message-ID: <20081114.145218.125819122.davem@davemloft.net>
References: <491D8C1A.5060003@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44743
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751641AbYKNWwS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Nov 2008 17:52:18 -0500
In-Reply-To: <491D8C1A.5060003@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Fri, 14 Nov 2008 17:32:58 +0300

> This is the next page of the scm recursion story (the commit 
> f8d570a4 net: Fix recursive descent in __scm_destroy()).
> 
> In function scm_fp_dup(), the INIT_LIST_HEAD(&fpl->list) of newly
> created fpl is done *before* the subsequent memcpy from the old 
> structure and thus the freshly initialized list is overwritten.
> 
> But that's OK, since this initialization is not required at all,
> since the fpl->list is list_add-ed at the destruction time in any
> case (and is unused in other code), so I propose to drop both
> initializations, rather than moving it after the memcpy.
> 
> Please, correct me if I miss something significant.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Yep, this is totally correct.

Linus even noticed this in my original patch but kept them there
because they seemed harmless to him.

Patch applied to net-2.6, thanks!
