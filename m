From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: unix: non blocking recvmsg() should not return
 -EINTR
Date: Wed, 26 Mar 2014 08:33:50 -0700
Message-ID: <1395848030.12610.210.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1395798147.12610.196.camel@edumazet-glaptop2.roam.corp.google.com>
	 <063D6719AE5E284EB5DD2968C1650D6D0F6E9790@AcuExch.aculab.com>
	 <87zjkd802t.fsf@sable.mobileactivedefense.com>
	 <1395847524.12610.208.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Laight <David.Laight@ACULAB.COM>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:58091 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750956AbaCZPdw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2014 11:33:52 -0400
Received: by mail-pd0-f181.google.com with SMTP id p10so1998354pdj.26
        for <netdev@vger.kernel.org>; Wed, 26 Mar 2014 08:33:52 -0700 (PDT)
In-Reply-To: <1395847524.12610.208.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-03-26 at 08:25 -0700, Eric Dumazet wrote:

> Look at what we do for AF_INET. We handle this the proper way.
> 
> If we are 'interrupted' by a signal while sleeping in lock_sock(),
> recvmsg() on a non blocking socket, we return -EAGAIN properly, not
> -EINTR.
> 
> Fact that we potentially sleep to get the socket lock is hidden for the
> user, its an implementation detail of the kernel.

And this is done pretty much the same way I did in my patch :

if (signal_pending(current)) {
    copied = timeo ? sock_intr_errno(timeo) : -EAGAIN;
    break;
}
