From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Receive processing stops when dev->poll returns 1
Date: Thu, 5 Aug 2010 10:37:15 -0700
Message-ID: <20100805103715.7d720cb0@nehalam>
References: <7866DA1F8D2D4541B87FEE88E633ABAA2B72081FB6@MNEXMB1.qlogic.org>
	<20100805090447.3f67d990@nehalam>
	<7866DA1F8D2D4541B87FEE88E633ABAA2B72081FDF@MNEXMB1.qlogic.org>
	<20100805092243.41671259@nehalam>
	<7866DA1F8D2D4541B87FEE88E633ABAA2B72081FE6@MNEXMB1.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Usha Srinivasan <usha.srinivasan@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:39000 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753679Ab0HERhR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Aug 2010 13:37:17 -0400
In-Reply-To: <7866DA1F8D2D4541B87FEE88E633ABAA2B72081FE6@MNEXMB1.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 5 Aug 2010 11:36:26 -0500
Usha Srinivasan <usha.srinivasan@qlogic.com> wrote:

>         int max = (budget - done);
>         t = min(<max-supported-by-driver>, max);
>         n = get-completions(comp_list);

You need to handle all completions pending in the poll, the code will
not call you back. So this min() is the problem.

-- 
