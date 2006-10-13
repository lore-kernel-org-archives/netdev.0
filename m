From: Jeff Garzik <jeff@garzik.org>
Subject: Re: use of tx_timeout in enet driver?
Date: Fri, 13 Oct 2006 12:31:07 -0400
Message-ID: <452FBF4B.8020803@garzik.org>
References: <E654CD0D-77A4-4B12-B2D5-FCB9ACFC191B@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:56550 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1751745AbWJMQbJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Oct 2006 12:31:09 -0400
To: Kumar Gala <galak@kernel.crashing.org>
In-Reply-To: <E654CD0D-77A4-4B12-B2D5-FCB9ACFC191B@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kumar Gala wrote:
> I'm working on a enet driver and trying to figure out what I should do 
> in the tx_timeout function.  The device I have doesn't interrupt on tx 
> completions so I already have a timer loop to check to see if there have 
> been any completions by looking at the ring pointers.
> 
> So should I do something like e100 does in using a work_queue to 
> effectively reset the card if we get a tx_timeout?

tx_timeout is largely a "traffic stopped, there are still pending TXs on 
the queue, see what happened" type event.  In theory, it should never 
happen as long as the driver gets carrier notification and other details 
right.  In practice, it is used as a backstop against hard-to-find 
driver bugs and hardware faults.

Generic practice is like e100:  reset the card from a workqueue, then 
restart TX processing.


