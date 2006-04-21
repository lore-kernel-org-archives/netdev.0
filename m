From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: e1000_down and tx_timeout worker race cleaning the transmit
 buffers
Date: Thu, 20 Apr 2006 17:10:13 -0700
Message-ID: <1145578214.3195.6.camel@rh4>
References: <200604201035.00100.shaw@vranix.com>
 <20060420233631.GA28380@gondor.apana.org.au>
 <20060420235149.GA28503@gondor.apana.org.au>
 <1145572617.3310.4.camel@rh4>
 <20060421012701.GA29053@gondor.apana.org.au>
 <20060421013340.GA29123@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: shawvrana@gmail.com, netdev@vger.kernel.org,
	"Auke Kok" <auke-jan.h.kok@intel.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:51462 "EHLO
	MMS3.broadcom.com") by vger.kernel.org with ESMTP id S1750890AbWDUBu0
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Apr 2006 21:50:26 -0400
To: "Herbert Xu" <herbert@gondor.apana.org.au>
In-Reply-To: <20060421013340.GA29123@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-04-21 at 11:33 +1000, Herbert Xu wrote:

> Actually, what if the tg3_close is followed by a tg3_open? That could
> produce a spurious reset which I suppose isn't that bad.

Yes, an extra reset. And yes, it isn't too bad.

> Also if the
> module is unloaded bad things will happen as well.

In tg3_remove_one(), we call flush_scheduled_work() in case the
reset_task is still pending. Here, it is safe to call
flush_scheduled_work() because we're not holding the rtnl. Again, when
it runs, nothing bad will happen because it will see netif_running() ==
0.


