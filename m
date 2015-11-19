From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Add a SOCK_DESTROY operation to close sockets from userspace
Date: Thu, 19 Nov 2015 14:07:55 -0800
Message-ID: <1447970875.22599.265.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAKD1Yr2OgJT0GsrTuws0oapobrU+ML3NpBNBXizg6q035PH4MA@mail.gmail.com>
	 <20151119.005318.838757439536205791.davem@davemloft.net>
	 <CANP3RGcPRzSL06qZB9oewrvN_AUUodnYzXQO=itoK40z64x8Yw@mail.gmail.com>
	 <20151119.104811.1447518072450380661.davem@davemloft.net>
	 <1447949964.22599.220.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CALx6S363gYA37GnEuArp+PKVjFdLchB_66zuLF5kJnSFKF4t6Q@mail.gmail.com>
	 <1447969264.22599.253.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CALx6S374xUUzWXUgA27PubceyDckrrfTiq7wvkLxXa0NacqqZA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	zenczykowski <zenczykowski@gmail.com>,
	Lorenzo Colitti <lorenzo@google.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>, Erik Kline <ek@google.com>,
	Dmitry Torokhov <dtor@google.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:32996 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934406AbbKSWH5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2015 17:07:57 -0500
Received: by pabfh17 with SMTP id fh17so96839066pab.0
        for <netdev@vger.kernel.org>; Thu, 19 Nov 2015 14:07:57 -0800 (PST)
In-Reply-To: <CALx6S374xUUzWXUgA27PubceyDckrrfTiq7wvkLxXa0NacqqZA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-11-19 at 13:53 -0800, Tom Herbert wrote:

> That covers the case where the local address is removed, but the not
> the case where the network manager is informed of an error in the path
> and wants to signal the application. My understanding was that
> SIOCKILLADDR would work for the first case, but this patch was need to
> cover the second case.
> 
> btw, instead of closing the TCP socket can we just report an error and
> wake up the application without affecting the connection? That is this
> just becomes an error on the socket. The response by the application
> will be the same in any case, porbablly just close the socket and try
> to reestablish the connection.

I thought this was the patch intent ?

Application gets a EPOLLIN|EPOLLOUT|POLLERR notification (if it is
willing to receive it, or blocked in a socket syscall) and closes the
socket.

         sk->sk_err = ETIMEDOUT;
         sk->sk_error_report(sk);
         tcp_done(sk);

If this sequence is not doing the job, then we have other worries in our
stack.
