From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3 net-next 1/4] net: SO_INCOMING_CPU setsockopt()
 support
Date: Fri, 09 Oct 2015 02:45:46 -0700
Message-ID: <1444383946.27760.50.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1444358004-26483-1-git-send-email-edumazet@google.com>
	 <1444358004-26483-2-git-send-email-edumazet@google.com>
	 <CALx6S36E7gO0YLadaayiXiJXhaveirumLZ-hiYJQuxrpObjZJQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
	"David S . Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:33558 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754897AbbJIJpt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Oct 2015 05:45:49 -0400
Received: by pacex6 with SMTP id ex6so82762922pac.0
        for <netdev@vger.kernel.org>; Fri, 09 Oct 2015 02:45:48 -0700 (PDT)
In-Reply-To: <CALx6S36E7gO0YLadaayiXiJXhaveirumLZ-hiYJQuxrpObjZJQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-10-08 at 20:40 -0700, Tom Herbert wrote:

> Do we care about losing this optimization? It's not done in IPv4 but I
> can imagine that there is some arguments that address comparisons in
> IPv6 are more expensive hence this might make sense...

I do not think we care. You removed the 'optimization' in IPv4 in commit
ba418fa357a7b ("soreuseport: UDP/IPv4 implementation") back in 2013 and
really no one noticed.

The important factor here is the number of cache lines taken to traverse
the list...
