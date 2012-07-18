From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cipso: don't follow a NULL pointer when setsockopt()
 is called
Date: Wed, 18 Jul 2012 09:02:06 -0700 (PDT)
Message-ID: <20120718.090206.1605115996207288596.davem@davemloft.net>
References: <20120717210738.22790.23522.stgit@sifl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: pmoore@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35062 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751253Ab2GRQCG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2012 12:02:06 -0400
In-Reply-To: <20120717210738.22790.23522.stgit@sifl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Moore <pmoore@redhat.com>
Date: Tue, 17 Jul 2012 17:07:47 -0400

> As reported by Alan Cox, and verified by Lin Ming, when a user
> attempts to add a CIPSO option to a socket using the CIPSO_V4_TAG_LOCAL
> tag the kernel dies a terrible death when it attempts to follow a NULL
> pointer (the skb argument to cipso_v4_validate() is NULL when called via
> the setsockopt() syscall).
> 
> This patch fixes this by first checking to ensure that the skb is
> non-NULL before using it to find the incoming network interface.  In
> the unlikely case where the skb is NULL and the user attempts to add
> a CIPSO option with the _TAG_LOCAL tag we return an error as this is
> not something we want to allow.
> 
> A simple reproducer, kindly supplied by Lin Ming, although you must
> have the CIPSO DOI #3 configure on the system first or you will be
> caught early in cipso_v4_validate():
 ...
> CC: Lin Ming <mlin@ss.pku.edu.cn>
> Reported-by: Alan Cox <alan@lxorguk.ukuu.org.uk>
> Signed-off-by: Paul Moore <pmoore@redhat.com>

Applied and queued up for -stable, thanks Paul.
