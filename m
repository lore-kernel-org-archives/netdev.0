From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: e1000_down and tx_timeout worker race cleaning the transmit
 buffers
Date: Thu, 20 Apr 2006 18:24:36 -0700
Message-ID: <1145582676.3195.18.camel@rh4>
References: <1145578214.3195.6.camel@rh4>
 <E1FWlWa-0007hN-00@gondolin.me.apana.org.au>
 <20060421024024.GA29644@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: shawvrana@gmail.com, netdev@vger.kernel.org,
	auke-jan.h.kok@intel.com, davem@davemloft.net, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:22034 "EHLO
	mms2.broadcom.com") by vger.kernel.org with ESMTP id S1750905AbWDUDEz
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Apr 2006 23:04:55 -0400
To: "Herbert Xu" <herbert@gondor.apana.org.au>
In-Reply-To: <20060421024024.GA29644@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-04-21 at 12:40 +1000, Herbert Xu wrote:

> One simple solution is to establish a separate queue for RTNL-holding
> users or vice versa for non-RTNL holding networking users.  That
> would allow the drivers to safely flush the non-RTNL queue while
> holding the RTNL.

You mean a separate workqueue for net drivers to use instead of the
keventd_wq? Yeah, I think that'll work. Each driver can also create its
own workqueue but that may be a bit more wasteful.

