From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][NET]: Fix wrong interpretation of some copy_to_user()
 results.
Date: Fri, 25 Apr 2008 01:48:30 -0700 (PDT)
Message-ID: <20080425.014830.98287734.davem@davemloft.net>
References: <48119953.6060808@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47394
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756899AbYDYIsb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Apr 2008 04:48:31 -0400
In-Reply-To: <48119953.6060808@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Fri, 25 Apr 2008 12:41:55 +0400

> I found some places, that erroneously return the value obtained from
> the copy_to_user() call: if some amount of bytes were not able to get
> to the user (this is what this one returns) the proper behavior is to
> return the -EFAULT error, not that number itself.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

I gues you're not a real kernel programmer unless you've made this
mistake at least once :-)  It kind of prove this is a bad interface,
since it's so easy to use incorrectly.

This was already caught in a tcp_probe fix I applied earlier today,
so I removed that part.

The rest is applied and I'll queue for -stable, thanks Pavel.
