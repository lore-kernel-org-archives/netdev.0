From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Receive processing stops when dev->poll returns 1
Date: Thu, 5 Aug 2010 09:22:43 -0700
Message-ID: <20100805092243.41671259@nehalam>
References: <7866DA1F8D2D4541B87FEE88E633ABAA2B72081FB6@MNEXMB1.qlogic.org>
	<20100805090447.3f67d990@nehalam>
	<7866DA1F8D2D4541B87FEE88E633ABAA2B72081FDF@MNEXMB1.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Usha Srinivasan <usha.srinivasan@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:57869 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755225Ab0HEQWp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Aug 2010 12:22:45 -0400
In-Reply-To: <7866DA1F8D2D4541B87FEE88E633ABAA2B72081FDF@MNEXMB1.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 5 Aug 2010 11:11:51 -0500
Usha Srinivasan <usha.srinivasan@qlogic.com> wrote:

> Thanks for your response. What you said is exactly what my driver is doing:
> 
> 
> <= 2.6.23 
> Calls netif_rx_complete if done < budget; decrements quota & *budget by done; returns 0 if done < budget and 1 otherwise.
> 
> When 1 is returned, I encounter the problem I described)
> 
> > 2.6.23
> Calls napi-complete if done < budget; returns done.
> 
> When done==budget, I encounter the problem I described.
> 
> Any ideas?

Ignore last mail...

If you done == budget, the poll will be recalled (after other drivers).
If quantum exhausts, then it gets called it gets deferred to ksoftirq
thread.

One possibility is that the driver is looking at wrong parameter
for budget and is exceeding the requested value. Please post your code.
