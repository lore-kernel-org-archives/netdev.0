From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] b44: properly use pr_fmt()
Date: Tue, 24 Apr 2012 00:47:45 -0400 (EDT)
Message-ID: <20120424.004745.1479792296922367681.davem@davemloft.net>
References: <1335235603-32420-1-git-send-email-mcgrof@do-not-panic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: zambrano@broadcom.com, netdev@vger.kernel.org
To: mcgrof@do-not-panic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:35422 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751499Ab2DXEsD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Apr 2012 00:48:03 -0400
In-Reply-To: <1335235603-32420-1-git-send-email-mcgrof@do-not-panic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Date: Mon, 23 Apr 2012 19:46:43 -0700

> From: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
> 
> pr_fmt() is either defined or we redefine it. Typically
> drivers define it prior to including printk.h but this
> is done under the assumption that no other subsystem
> it uses has already defined pr_fmt(). In such cases
> pr_fmt() should be undefined and redefined.
> 
> Doing this properly shaves down compilation time quite
> considerably.
> 
> Signed-off-by: Luis R. Rodriguez <mcgrof@do-not-panic.com>

Every driver defines pr_fmt then includes the headers.  I do not
see any other place which performs the initial undef of pr_fmt
like you want to start doing here.

If there is a reason we should start doing this, it would appear
to be a universal reason, not one specific to this driver.  If
that's the case, we should formally agree to this and then work
on gradually converting all the drivers in reasonably sized chunks.

Either way I can't apply this patch as-is, sorry Luis.
