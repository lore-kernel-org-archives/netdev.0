From: "George B." <georgeb@gmail.com>
Subject: Re: [PATCH] tcp: disallow bind() to reuse addr/port
Date: Wed, 27 Apr 2011 11:45:37 -0700
Message-ID: <BANLkTinXr5udWZp9Kpp5wxr7GhiVfqWOaQ@mail.gmail.com>
References: <1294140172.3579.81.camel@edumazet-laptop>
	<AANLkTimuNM7vmeR89WKXtrUbJO1Wt1ivp9y=bQvtWg0j@mail.gmail.com>
	<1294744462.2927.53.camel@edumazet-laptop>
	<20110111.140336.128591591.davem@davemloft.net>
	<BANLkTi=176iFKUHn351OWOZUSaUBkgKf2Q@mail.gmail.com>
	<1303926014.3166.101.camel@edumazet-laptop>
	<BANLkTin-KhU0KqSuUpbCi2STnnxszO5x=Q@mail.gmail.com>
	<1303927352.3166.125.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:39279 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753969Ab1D0Spj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2011 14:45:39 -0400
Received: by wya21 with SMTP id 21so1488991wya.19
        for <netdev@vger.kernel.org>; Wed, 27 Apr 2011 11:45:37 -0700 (PDT)
In-Reply-To: <1303927352.3166.125.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> It causes known regressions for programs that expect to be able to use
> SO_REUSEADDR to shutdown a socket, then successfully rebind another
> socket to the same ID.
>
> Programs such as haproxy and amavisd expect this to work.
>
> This should fix kernel bugzilla 32832.


Thank you very much for the clarification.  It just seems on the
surface like it should be a simple problem (don't they all, at
first?).  Instead of checking to see if we have more than the number
of ephemeral ports in use globally, see if we have more than that
number in use on the requested IP address.  The problem I am having is
if the number of ports in use globally is greater than the number of
configured ephemeral ports, I can't open a socket on a specific source
IP even though that IP has plenty of ports available.  It would seem
like a simple bounds checking problem.

Thanks again for taking the time to respond.

George
