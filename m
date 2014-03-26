From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: unix: non blocking recvmsg() should not return
 -EINTR
Date: Wed, 26 Mar 2014 15:35:22 -0700
Message-ID: <1395873322.12610.272.camel@edumazet-glaptop2.roam.corp.google.com>
References: <87zjkd802t.fsf@sable.mobileactivedefense.com>
	 <1395847524.12610.208.camel@edumazet-glaptop2.roam.corp.google.com>
	 <87y4zw7ngi.fsf@sable.mobileactivedefense.com>
	 <20140326.170514.1793472148242469413.davem@davemloft.net>
	 <87a9cc7j1o.fsf@sable.mobileactivedefense.com>
	 <1395870280.12610.252.camel@edumazet-glaptop2.roam.corp.google.com>
	 <8761n07gxy.fsf@sable.mobileactivedefense.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, David.Laight@ACULAB.COM,
	netdev@vger.kernel.org
To: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f54.google.com ([209.85.160.54]:60976 "EHLO
	mail-pb0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754708AbaCZWfY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2014 18:35:24 -0400
Received: by mail-pb0-f54.google.com with SMTP id ma3so2596662pbc.27
        for <netdev@vger.kernel.org>; Wed, 26 Mar 2014 15:35:24 -0700 (PDT)
In-Reply-To: <8761n07gxy.fsf@sable.mobileactivedefense.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-03-26 at 22:06 +0000, Rainer Weikusat wrote:

> That would be a seriously bizarre idea. The thread of execution which
> does the supposed-to-be-non-blocking call shouldn't become blocked for
> an indefinite time. Which means it should not wait indefinitely for a
> thread which - in turn - waits indefinitely for an external event (and
> hence, the original problem should never have existed to begin with as
> there would neither be an opportunity nor a reason to interrupt in the
> non-blocking case).


This is not what your program do.

Your program does a read() on a blocking fd.

If another thread does a close() on this fd or change non blocking flag,
it does or it doesn't impact first thread.

It is not part of any specification. So nobody would rely on this.


> BTW, while these are things which are of some interest to me (even of
> some professional interest), I don't exactly get paid for these kind of
> discussions, have some real work to do, and the way people interact on
> LKML is seriously more aggressive then I can stand for a prolonged time,
> so can we please end this discussion here while it - if only for a
> change - hasn't yet degraded into an all out mutual extermination fight?

...

I was not particularly aggressive, I tried to explain my points after
you said my patch was not the right way, and that thousands of
applications had to be identified for potential problems and patched
instead.

If you do not have time, I suggest you simply not spend time on this.

I CCed you because you were the patch author, not because I wanted your
approval or any comment, and not because I wanted to hurt you in any
way.

Thats the standard procedure for all patches, even ones coming from you.
