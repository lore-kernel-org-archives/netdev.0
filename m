From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [patch] wan/x25_asy: integer overflow in x25_asy_change_mtu()
Date: Thu, 17 Jul 2014 11:58:19 +0300
Message-ID: <20140717085818.GG18338@mwanda>
References: <20140717080310.GB477@mwanda>
 <063D6719AE5E284EB5DD2968C1650D6D1727688E@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:27099 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755365AbaGQI6T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2014 04:58:19 -0400
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1727688E@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 17, 2014 at 08:45:58AM +0000, David Laight wrote:
> From: Dan Carpenter
> > If "newmtu * 2 + 4" is too large then it can cause an integer overflow
> > leading to memory corruption.  Btw, "newmtu" is not allowed to be a
> > negative number because of the check in dev_set_mtu(), so that's ok.
> 
> This still allows large numbers to be used to allocate almost all of
> kernel memory - causing massive issues elsewhere.
> 
> I'd have thought a 'sanity' limit on the mtu would be more appropriate.
> I've no idea which mtu is being changed here, and I can't even remember
> the x.25 protocol well enough if it is an x.25 level 3 limit.
> But I suspect that a 'sanity' bound to 1MB won't cause any grief.
> 

I agree that a sanity check is probably better but I don't think kmalloc
can allocate more than 128k (or something.  It's arch dependent as
well).  So using 1MB is almost no different from my original patch.

What's a better, smaller limit?

regards,
dan carpenter
