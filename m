From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2/14] nes: device structures and defines
Date: Wed, 08 Aug 2007 12:59:08 -0400
Message-ID: <46B9F65C.9060906@garzik.org>
References: <200708080045.l780jE9E004667@neteffect.com> <200708081830.20129.mb@bu3sch.de> <46B9F054.4030000@garzik.org> <200708081843.36370.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Roland Dreier <rdreier@cisco.com>,
	Andi Kleen <andi@firstfloor.org>, ggrundstrom@neteffect.com,
	ewg@lists.openfabrics.org, netdev@vger.kernel.org
To: Michael Buesch <mb@bu3sch.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:37754 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759780AbXHHQ7N (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Aug 2007 12:59:13 -0400
In-Reply-To: <200708081843.36370.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Buesch wrote:
> writel doesn't guarantee flushing either.
> readl does.


Not quite -- there are multiple kinds of flushing.  You're thinking 
about flushing across PCI bridges, which is correct, but you also have 
CPU write posting and CPU write ordering and such.

Without taking all that into account, you might be tempted to think that 
__raw_readl() will perform all flushes necessary following a 
__raw_writel() -- but that would be incorrect.

	Jeff


