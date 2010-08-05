From: Usha Srinivasan <usha.srinivasan@qlogic.com>
Subject: RE: Receive processing stops when dev->poll returns 1
Date: Thu, 5 Aug 2010 13:11:07 -0500
Message-ID: <7866DA1F8D2D4541B87FEE88E633ABAA2B72082003@MNEXMB1.qlogic.org>
References: <7866DA1F8D2D4541B87FEE88E633ABAA2B72081FB6@MNEXMB1.qlogic.org>
	<20100805090447.3f67d990@nehalam>
	<7866DA1F8D2D4541B87FEE88E633ABAA2B72081FDF@MNEXMB1.qlogic.org>
	<20100805092243.41671259@nehalam>
	<7866DA1F8D2D4541B87FEE88E633ABAA2B72081FE6@MNEXMB1.qlogic.org>
 <20100805103715.7d720cb0@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexcashub1.qlogic.com ([198.70.193.61]:54380 "EHLO
	avexcashub1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754209Ab0HESLK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Aug 2010 14:11:10 -0400
In-Reply-To: <20100805103715.7d720cb0@nehalam>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen,
The min is inside a while loop; it is purely used to limit the number of completions that are retrieved at-a-time.  The outer while loops ensuring that all the completions are handled until budget is reached or there are no completions left. Please look again at the code I sent you.
Usha

-----Original Message-----
From: Stephen Hemminger [mailto:shemminger@vyatta.com] 
Sent: Thursday, August 05, 2010 1:37 PM
To: Usha Srinivasan
Cc: netdev@vger.kernel.org
Subject: Re: Receive processing stops when dev->poll returns 1

On Thu, 5 Aug 2010 11:36:26 -0500
Usha Srinivasan <usha.srinivasan@qlogic.com> wrote:

>         int max = (budget - done);
>         t = min(<max-supported-by-driver>, max);
>         n = get-completions(comp_list);

You need to handle all completions pending in the poll, the code will
not call you back. So this min() is the problem.

-- 

