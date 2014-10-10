From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net 0/5] net: fix races accessing page->_count
Date: Fri, 10 Oct 2014 04:37:02 -0700
Message-ID: <1412941022.9362.7.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1412918694-22882-1-git-send-email-edumazet@google.com>
	 <063D6719AE5E284EB5DD2968C1650D6D174C833D@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: 'Eric Dumazet' <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Alexander Duyck <alexander.h.duyck@redhat.com>,
	Andres Lagar-Cavilla <andreslc@google.com>,
	Greg Thelen <gthelen@google.com>,
	Hugh Dickins <hughd@google.com>,
	David Rientjes <rientjes@google.com>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:61550 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753484AbaJJLhF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2014 07:37:05 -0400
Received: by mail-pa0-f47.google.com with SMTP id rd3so1592089pab.20
        for <netdev@vger.kernel.org>; Fri, 10 Oct 2014 04:37:04 -0700 (PDT)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D174C833D@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-10-10 at 10:02 +0000, David Laight wrote:
> From: Eric Dumazet
> > This is illegal to use atomic_set(&page->_count, ...) even if we 'own'
> > the page. Other entities in the kernel need to use get_page_unless_zero()
> > to get a reference to the page before testing page properties, so we could
> > loose a refcount increment.
> 
> Plausibly the atomic_inc() could be avoided by allocating the page
> with multiple references, or by gabbing a lot of extra references
> and keeping a local count of when they are 'used' (by passing
> ownership onwards).

Well, this is the idea already in place.

I assume you read __netdev_alloc_frag() ?

Note this is a fix, and a fix should be minimal and obvious.
