From: Jeremy Fitzhardinge <jeremy@goop.org>
Subject: Re: [PATCH] xen-netfront: Avoid deref'ing skbafter it is potentially
 freed.
Date: Tue, 14 Aug 2007 11:16:08 -0700
Message-ID: <46C1F168.5050102@goop.org>
References: <46C0B6FD.7020701@goop.org> <200708140203.30711.jesper.juhl@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, NetDev <netdev@vger.kernel.org>,
	Keir Fraser <keir@xensource.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Jesper Juhl <jesper.juhl@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw.goop.org ([64.81.55.164]:40302 "EHLO mail.goop.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753354AbXHNSSF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Aug 2007 14:18:05 -0400
In-Reply-To: <200708140203.30711.jesper.juhl@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jesper Juhl wrote:
> This moves the updating of both tx_bytes and tx_packets inside the 
> spinlock, but as far as I can see we only _really_ need to move the 
> tx_bytes update. Considering that we generally want to do as little 
> work as possible while holding a lock, wouldn't the following be 
> slightly better?
>   

Hm, I think it would be better to keep them together.  The second add is
going to be pretty much free, particularly since the tx_bytes add will
probably pull tx_packets into cache.

I have a followup patch to convert it to using the netdevice stats
structure, which will definitely put them in the same cacheline (though
perhaps the stats structure should group tx and rx members together?).

    J

    J
