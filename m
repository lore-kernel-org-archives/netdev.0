From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: unix: non blocking recvmsg() should not return
 -EINTR
Date: Wed, 26 Mar 2014 08:25:24 -0700
Message-ID: <1395847524.12610.208.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1395798147.12610.196.camel@edumazet-glaptop2.roam.corp.google.com>
	 <063D6719AE5E284EB5DD2968C1650D6D0F6E9790@AcuExch.aculab.com>
	 <87zjkd802t.fsf@sable.mobileactivedefense.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Laight <David.Laight@ACULAB.COM>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:37448 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751432AbaCZPZ0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2014 11:25:26 -0400
Received: by mail-pa0-f41.google.com with SMTP id fa1so2069607pad.14
        for <netdev@vger.kernel.org>; Wed, 26 Mar 2014 08:25:26 -0700 (PDT)
In-Reply-To: <87zjkd802t.fsf@sable.mobileactivedefense.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-03-26 at 15:13 +0000, Rainer Weikusat wrote:

> (This is from memory) If there's a thread blocked in recv and another
> blocked on the lock and the kernel selects the thread blocked on the lock
> for handling the signal, the signal won't be handled until some data is
> received on the socket, ie, possibly never.

Look at what we do for AF_INET. We handle this the proper way.

If we are 'interrupted' by a signal while sleeping in lock_sock(),
recvmsg() on a non blocking socket, we return -EAGAIN properly, not
-EINTR.

Fact that we potentially sleep to get the socket lock is hidden for the
user, its an implementation detail of the kernel.

We never return -EINTR, as stated in manpage for non blocking sockets.

Only AF_UNIX in recent kernels introduced this API change.
