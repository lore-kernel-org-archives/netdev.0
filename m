From: Jeff Garzik <jeff@garzik.org>
Subject: Re: hard_start_xmit struct sk_buff read-only?
Date: Sat, 22 Dec 2007 03:50:02 -0500
Message-ID: <476CCFBA.2010305@garzik.org>
References: <249190.1925.qm@web52006.mail.re2.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Matti Linnanvuori <mattilinnanvuori@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:44016 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750780AbXLVIuG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 22 Dec 2007 03:50:06 -0500
In-Reply-To: <249190.1925.qm@web52006.mail.re2.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Matti Linnanvuori wrote:
> An old article about Linux's network drivers mentioned
> that the struct sk_buff whose pointer is passed to a
> driver's hard_start_xmit function is read-only to the
> function. Is that still so? If it is, there is no
> mention about it in the kernel tree as far as I know.

This begs the question, what are you trying to do?  ;-)

In terms of object lifetimes, control passes to the net driver when 
->hard_start_xmit() is called, but that does not mean you can freely 
scribble over things -- the skb may have been cloned, its destructor 
callback still needs to be called (via dev_kfree_skb), etc.

	Jeff



