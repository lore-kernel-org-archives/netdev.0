From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: [net-next 2/8] bnx2x: add select queue callback
Date: Sun, 12 Dec 2010 12:25:03 +0200
Message-ID: <1292149503.21210.12.camel@lb-tlvb-eilong.il.broadcom.com>
References: <1291896556.8745.7.camel@lb-tlvb-dmitry>
 <20101210.141131.241939045.davem@davemloft.net>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "Dmitry Kravkov" <dmitry@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	vladz@broadcom.com
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1942 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751796Ab0LLKZR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 12 Dec 2010 05:25:17 -0500
In-Reply-To: <20101210.141131.241939045.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2010-12-10 at 14:11 -0800, David Miller wrote:
> From: "Dmitry Kravkov" <dmitry@broadcom.com>
> Date: Thu, 9 Dec 2010 14:09:16 +0200
> 
> > +#endif
> > +	/* Select queue (if defined) adjust for fcoe */
> > +	fp_index = skb_tx_hash(dev, skb) - FCOE_CONTEXT_USE;
> > +
> > +	return (fp_index >= 0 ? fp_index : 0);
> 
> This doesn't make any sense, and it's one of the reasons I really
> hate the fact that drivers sometimes need to override the
> select_queue method.
> 
> Because 9 times out of 10 they get it wrong.
> 
> You're mapping queues 0 --> FCOE_CONTEXT_USE to zero.
> 
> But that's not what you actually want.
> 
> You're actually trying to make non-FCOE traffic hash only amongst the
> non-FCOE queues.
> 
> So make your code actually do that instead of screwing up the
> distribution of the hash result.
> 

Indeed, the current suggestion is giving queue 0 double weight compared
to all other queues just so the skb_tx_hash will be used as is to
benefit from future enhancement changes to it. We will re-spin this
patch and move the content of the skb_tx_hash to __skb_tx_hash that will
receive the netdev->skb_real_num_tx_queues as a parameter - this way, we
can call the __skb_tx_hash with a lower number.

Thanks,
Eilon




