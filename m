From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/1] net: Add SO_REUSEPORT_LISTEN_OFF socket option as
 drain mode
Date: Sat, 26 Sep 2015 18:04:02 -0700
Message-ID: <1443315842.3273.3.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1443313848-751-1-git-send-email-tolga.ceylan@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Tolga Ceylan <tolga.ceylan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:33010 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754503AbbI0BEF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Sep 2015 21:04:05 -0400
Received: by pacex6 with SMTP id ex6so139928099pac.0
        for <netdev@vger.kernel.org>; Sat, 26 Sep 2015 18:04:04 -0700 (PDT)
In-Reply-To: <1443313848-751-1-git-send-email-tolga.ceylan@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2015-09-26 at 17:30 -0700, Tolga Ceylan wrote:
> For applications using SO_REUSEPORT listeners, there is
> no clean way to switch traffic on/off or add/remove
> listeners without dropping pending connections. With this
> patch, applications can turn off queueing of new connections
> for a specific listener socket which enables implementation of
> zero down time server applications.
> 
> For example, a popular web server nginx handles application
> configuration changes by forking new processes (listeners)
> and waiting for old processes (listeners) to finish up their
> processing. However, this approach is distruptive as removal
> of a listener will drop pending connections for that listener.
> Instead, with this patch, nginx can maintain two sets of listener
> socket pools to be used by old/new processes and switch traffic off/on
> using this socket option. Old processes set set this socket option
> to drain their existing queues.

What about listen(fd, 0) ?

Not sure we need to add a new socket option.

It makes sense to extend reuseport logic to ignore listeners with a 0
backlog (if not already done, I did not check)
