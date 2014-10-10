From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net 0/5] net: fix races accessing page->_count
Date: Fri, 10 Oct 2014 10:02:37 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D174C833D@AcuExch.aculab.com>
References: <1412918694-22882-1-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Alexander Duyck <alexander.h.duyck@redhat.com>,
	Andres Lagar-Cavilla <andreslc@google.com>,
	Greg Thelen <gthelen@google.com>,
	Hugh Dickins <hughd@google.com>,
	"David Rientjes" <rientjes@google.com>
To: 'Eric Dumazet' <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:60336 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751306AbaJJKES convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2014 06:04:18 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 09525-07 for <netdev@vger.kernel.org>;
 Fri, 10 Oct 2014 11:04:07 +0100 (BST)
In-Reply-To: <1412918694-22882-1-git-send-email-edumazet@google.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet
> This is illegal to use atomic_set(&page->_count, ...) even if we 'own'
> the page. Other entities in the kernel need to use get_page_unless_zero()
> to get a reference to the page before testing page properties, so we could
> loose a refcount increment.

Plausibly the atomic_inc() could be avoided by allocating the page
with multiple references, or by gabbing a lot of extra references
and keeping a local count of when they are 'used' (by passing
ownership onwards).

	David
