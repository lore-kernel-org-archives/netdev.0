From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 16603] New: send of data > 4 GB fails on 64
 bit systems
Date: Mon, 27 Sep 2010 19:41:28 -0700 (PDT)
Message-ID: <20100927.194128.193725825.davem@davemloft.net>
References: <bug-16603-10286@https.bugzilla.kernel.org/>
	<20100927161540.776f748e.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, bono@onlinehome.de
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38495
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757938Ab0I1ClJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Sep 2010 22:41:09 -0400
In-Reply-To: <20100927161540.776f748e.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>
Date: Mon, 27 Sep 2010 16:15:40 -0700

> Yes, I think seglen should be size_t.  Do you know if making that
> change fixes the bug?

Oh boy, what a rats nest.

Just scanning generically I see that net/core/iovec.c:verify_iovec()
has similar issues, it should probably use "long" instead of "int"
because it's trying to prevent the return value being interpreted
as an error code.

So if you fix that and make it return "long" this leads to another
set of problems, even if you fix that TCP bit sys_sendmsg() holds
the total length in an 'int' too.  So more stuff to fix.

I'll try to do the whole audit, but no promises ;)
