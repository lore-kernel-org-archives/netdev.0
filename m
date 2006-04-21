From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: e1000_down and tx_timeout worker race cleaning the transmit
 buffers
Date: Thu, 20 Apr 2006 18:33:28 -0700
Message-ID: <1145583208.3195.22.camel@rh4>
References: <200604201035.00100.shaw@vranix.com>
 <20060421013340.GA29123@gondor.apana.org.au>
 <1145578214.3195.6.camel@rh4> <200604201942.07009.shawvrana@acm.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Herbert Xu" <herbert@gondor.apana.org.au>, netdev@vger.kernel.org,
	"Auke Kok" <auke-jan.h.kok@intel.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:44040 "EHLO
	mms1.broadcom.com") by vger.kernel.org with ESMTP id S932220AbWDUDNn
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Apr 2006 23:13:43 -0400
To: "Shaw Vrana" <shawvrana@gmail.com>
In-Reply-To: <200604201942.07009.shawvrana@acm.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-04-20 at 19:42 -0700, Shaw Vrana wrote:

> I'll bite!  Here's a patch to add a call to flush_scheduled_work() in 
> e1000_down.  It's against 2.6.16.9.
> 
You're not following our discussion. It is not safe to call
flush_scheduled_work() in a driver's close() because it is holding the
rtnl and can deadlock with linkwatch_event() if it happens to be on the
workqueue.

