From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: e1000_down and tx_timeout worker race cleaning the transmit
 buffers
Date: Thu, 20 Apr 2006 15:36:57 -0700
Message-ID: <1145572617.3310.4.camel@rh4>
References: <200604201035.00100.shaw@vranix.com>
 <20060420233631.GA28380@gondor.apana.org.au>
 <20060420235149.GA28503@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: shawvrana@gmail.com, netdev@vger.kernel.org,
	"Auke Kok" <auke-jan.h.kok@intel.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:60677 "EHLO
	mms1.broadcom.com") by vger.kernel.org with ESMTP id S932168AbWDUARL
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Apr 2006 20:17:11 -0400
To: "Herbert Xu" <herbert@gondor.apana.org.au>
In-Reply-To: <20060420235149.GA28503@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-04-21 at 09:51 +1000, Herbert Xu wrote:

> 
> Actually TG3 is buggy too.  If the reset task is scheduled but
> isn't running yet there is no synchronisation here to prevent the
> reset task from running after tg3_close releases the tp lock.
> 

If we're in tg3_close() and the reset task isn't running yet, tg3_close
() will proceed. However, when the reset task finally runs, it will see
that netif_running() is zero and will just return.


