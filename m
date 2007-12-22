From: Matti Linnanvuori <mattilinnanvuori@yahoo.com>
Subject: Re: hard_start_xmit struct sk_buff read-only?
Date: Sat, 22 Dec 2007 10:18:08 +0100 (CET)
Message-ID: <166884.22908.qm@web52012.mail.re2.yahoo.com>
References: <476CCFBA.2010305@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web52012.mail.re2.yahoo.com ([206.190.48.28]:47409 "HELO
	web52012.mail.re2.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1757078AbXLVJYv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Dec 2007 04:24:51 -0500
In-Reply-To: <476CCFBA.2010305@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--- Jeff Garzik <jeff@garzik.org> schrieb:

> This begs the question, what are you trying to do? 
> ;-)

I have seen network drivers whose hard_start_xmit
function calls skb_push or skb_put to extend the used
data area of the struct skb_buff passed to the
function. That avoids allocating a new buffer and
copying the whole data area to it. The drivers
apparently do that because the device expects a
specific header or suffix in the DMA buffer it
handles.

> In terms of object lifetimes, control passes to the
> net driver when 
> ->hard_start_xmit() is called, but that does not
> mean you can freely 
> scribble over things -- the skb may have been
> cloned, its destructor 
> callback still needs to be called (via
> dev_kfree_skb), etc.

So I assume modifying the data or header area of
struct sk_buff is incorrect because it can break
cloned buffers.


      Heute schon einen Blick in die Zukunft von E-Mails wagen? www.yahoo.de/mail
