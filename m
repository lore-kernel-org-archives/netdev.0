From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 5/6] IP100A correct init and close step
Date: Fri, 18 Aug 2006 07:12:57 -0400
Message-ID: <44E5A0B9.9090502@pobox.com>
References: <1155841712.4532.19.camel@localhost.localdomain> <44E48281.1060504@pobox.com> <02ea01c6c28d$20943940$4964a8c0@icplus.com.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:55255 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S932417AbWHRLM7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2006 07:12:59 -0400
To: Jesse Huang <jesse@icplus.com.tw>
In-Reply-To: <02ea01c6c28d$20943940$4964a8c0@icplus.com.tw>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jesse Huang wrote:
> Hi Jeff:
> (1)Should I change to :
> spin_lock_irqsave(&np->lock,flags);
> reset_tx(dev);
> spin_lock_irqrestore(&np->lock,flags);
> 
> (2)I will remove date and author information out of source code comment.

Correct.

Also:

(3) Use iowrite16(), not writew().  I just noticed this bug. 
iowrite16() will work for both MMIO and IO cycles, writew() only works 
for MMIO.

(4) We need a description of why this change is needed.  What does 
writing 0x500 to DMACtrl actually do?  Why do we need to do this?

	Jeff



