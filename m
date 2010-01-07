From: Dhananjay Phadke <dhananjay.phadke@qlogic.com>
Subject: RE: [PATCHv2 NEXT 1/2] qlcnic: Qlogic ethernet driver for CNA
 devices
Date: Thu, 7 Jan 2010 10:40:02 -0800
Message-ID: <7608421F3572AB4292BB2532AE89D5658B0BAE95E4@AVEXMB1.qlogic.org>
References: <1262777154-31982-1-git-send-email-amit.salecha@qlogic.com>
	<1262777154-31982-2-git-send-email-amit.salecha@qlogic.com>
 <20100106111655.207e7414@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>,
	Amit Salecha <amit.salecha@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:12454 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753488Ab0AGSlq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2010 13:41:46 -0500
In-Reply-To: <20100106111655.207e7414@nehalam>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> * crb_lock is setup as rwlock but you only use as writer;
>  also isn't this already covered by mem_lock?
> 
> * mem_lock could/should be mutex
>  can ioremap want to sleep?

crb_lock and mem_lock are inherited from netxen_nic which
needed separate locks for indirect register and memory
access on NX2031 controllers.

You have already touched the reason they need to be separate,
on card memory is only read by applications and needs ioremap,
whereas registers may be accessed in atomic context.

-Dhananjay

