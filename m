From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v2] ipv6: fix inconsistent prefix route handling
Date: Sun, 16 Feb 2014 17:51:28 +0100
Message-ID: <20140216165128.GF8634@order.stressinduktion.org>
References: <5300DDB1.9000404@openwrt.org> <1392567954-25752-1-git-send-email-cyrus@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Steven Barth <cyrus@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:58853 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752508AbaBPQv3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Feb 2014 11:51:29 -0500
Content-Disposition: inline
In-Reply-To: <1392567954-25752-1-git-send-email-cyrus@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Feb 16, 2014 at 05:25:54PM +0100, Steven Barth wrote:
> -	if (ifp->flags & IFA_F_PERMANENT && !(ifp->flags & IFA_F_NOPREFIXROUTE))
> +	if (!(ifp->flags & IFA_F_NOPREFIXROUTE))
>  		action = check_cleanup_prefix_route(ifp, &expires);

This could too easily clean up valid on-link information if the address just
happens to be in the same subnet. Would (ifp-flags &
(IFA_F_PERMANENET|IFA_F_TEMPORARY) && !(...)) solve the problem, too?

Greetings,

  Hannes
