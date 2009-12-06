From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] inetpeer: optimizations
Date: Sun, 6 Dec 2009 21:18:24 +0100
Message-ID: <20091206201824.GA4159@ami.dom.local>
References: <4B1A4E07.4030804@gmail.com>
 <4B1AD0CD.4040407@gmail.com>
 <4B1B6F87.6050201@gmail.com>
 <20091206182210.GA3870@ami.dom.local>
 <4B1BFEBF.60901@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f227.google.com ([209.85.218.227]:51283 "EHLO
	mail-bw0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757517AbZLFUS3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Dec 2009 15:18:29 -0500
Received: by bwz27 with SMTP id 27so3065288bwz.21
        for <netdev@vger.kernel.org>; Sun, 06 Dec 2009 12:18:34 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <4B1BFEBF.60901@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Dec 06, 2009 at 07:58:07PM +0100, Eric Dumazet wrote:
> Yes, you miss something. We are not working on a true reference count variable.
> (p is referenced in avl tree but there is no +1 count for this reference)
> 
> Its more a usecount one, and p usecount can be 0 but p still in avl tree.
> 
> Even if we are the thread (A) doing 1 -> 0 transition, other thread (B)
> can find p and perform the opposite 0 -> 1 transition.
> 
> If (B) tries to unlink p before (A), it finds p already unlinked.
> 
> Then (A) links into unused list, while refcnt is still 1

This last thing can happen now too, but as I wrote, my idea was wrong,
nevertheless.

Jarek P.
