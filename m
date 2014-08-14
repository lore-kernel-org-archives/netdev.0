From: David Miller <davem@redhat.com>
Subject: Re: [PATCH net-next] lec: Use rtnl lock/unlock when updating MTU
Date: Thu, 14 Aug 2014 14:37:06 -0700 (PDT)
Message-ID: <20140814.143706.1833450188258591738.davem@redhat.com>
References: <201408141319.s7EDJl9l031767@thirdoffive.cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-atm-general@lists.sourceforge.net
To: chas@cmf.nrl.navy.mil
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:21727 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753162AbaHNVi0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Aug 2014 17:38:26 -0400
In-Reply-To: <201408141319.s7EDJl9l031767@thirdoffive.cmf.nrl.navy.mil>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chas Williams - CONTRACTOR <chas@cmf.nrl.navy.mil>
Date: Thu, 14 Aug 2014 09:19:47 -0400

> The LECS response contains the MTU that should be used.  Correctly
> synchronize with other layers when updating.
> 
> Signed-off-by: Chas Williams - CONTRACTOR <chas@cmf.nrl.navy.mil>

I don't think you can sleep from this function, which rtnl_lock() may
require.  Look elsewhere in this routine, it's doing GFP_ATOMIC
allocations even.
