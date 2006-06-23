From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH REPOST 1/2] Network Event Notifier Mechanism.
Date: Fri, 23 Jun 2006 13:26:47 -0700 (PDT)
Message-ID: <20060623.132647.39159829.davem@davemloft.net>
References: <20060623201918.32482.89765.stgit@stevo-desktop>
	<20060623201928.32482.69191.stgit@stevo-desktop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:43953
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1752031AbWFWU0r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Jun 2006 16:26:47 -0400
To: swise@opengridcomputing.com
In-Reply-To: <20060623201928.32482.69191.stgit@stevo-desktop>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Steve Wise <swise@opengridcomputing.com>
Date: Fri, 23 Jun 2006 15:19:28 -0500

> +struct netevent_route_change {
> +        int event;
> +        struct fib_info *fib_info;
> +};

It's not generic if you're putting ipv4 FIB route objects
in the datastructure.

This is so much unnecessary syntactic sugar for what you're
trying to accomplish.

Just pass a "void *", and have the type of the object defined by which
notifier it is.  This is exactly how all notifiers work today.

Then you don't need any new infrastructure at all.  The existing
notifier bits handle this kind of scheme already, no need to
invent new stuff.
