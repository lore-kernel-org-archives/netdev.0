From: "Matt Renzelmann" <mjr@cs.wisc.edu>
Subject: RE: [PATCH] ks8851: Fix missing mutex_lock/unlock
Date: Thu, 12 Apr 2012 15:56:25 -0500
Message-ID: <005a01cd18ee$bcc45940$364d0bc0$@cs.wisc.edu>
References: <1334261204-8554-1-git-send-email-mjr@cs.wisc.edu> <4F873C58.3000104@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <fbl@redhat.com>, <davem@davemloft.net>, <ben@simtec.co.uk>,
	<netdev@vger.kernel.org>
To: "'Stephen Boyd'" <sboyd@codeaurora.org>, <mjr@cs.wisc.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sabe.cs.wisc.edu ([128.105.6.20]:47823 "EHLO sabe.cs.wisc.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755582Ab2DLU4r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Apr 2012 16:56:47 -0400
In-Reply-To: <4F873C58.3000104@codeaurora.org>
Content-Language: en-us
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> This register is already read in the probe function and the lock is not
> held there so you seem to have missed a couple. I would guess it doesn't
> really matter tha we don't grab the lock though because the device isn't
> actively sending/receiving packets. How about this instead?
> 

The reason I didn't go that way was the request_irq call is not made until near
the end of probe.  I believe only the ks8851_rdreg16 call in the netdev_info
statement actually needs the mutex protection.  That said, the approach you
posted looks reasonable as well and may be clearer.  I'm unsure as to which way
is best.

Thanks everyone for your help,
Matt
