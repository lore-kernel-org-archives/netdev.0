From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH net-next-2.6] net: pskb_expand_head() optimization
Date: Sun, 12 Sep 2010 22:57:22 +0200
Message-ID: <20100912205722.GB2585@del.dom.local>
References: <20100911.203002.193707453.davem@davemloft.net>
 <20100912104534.GA2056@del.dom.local>
 <20100912.085833.226777368.davem@davemloft.net>
 <20100912.091353.71112923.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:63485 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753501Ab0ILU52 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Sep 2010 16:57:28 -0400
Received: by wyf22 with SMTP id 22so5398715wyf.19
        for <netdev@vger.kernel.org>; Sun, 12 Sep 2010 13:57:27 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20100912.091353.71112923.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Sep 12, 2010 at 09:13:53AM -0700, David Miller wrote:
> 
> BTW, Jarek, as to your idea to store a tail pointer in the shinfo, how
> will you sync that tail pointer in all of the shinfo instances
> referencing the frag list?
> 
> It simply can't work, we have to copy.

The question is if we need to sync at all? This is shared data at the
moment, so I can't imagine how the list (especialy doubly linked)
could be changed without locking? And even if it's possible, I doubt
copying e.g. like in your current patch can help when an skb is added
at the tail later.

Jarek P.
