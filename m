From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next 2/3] udp: Add udp early demux
Date: Wed, 02 Oct 2013 14:08:38 -0700
Message-ID: <1380748118.19002.125.camel@edumazet-glaptop.roam.corp.google.com>
References: <1380656025-8847-1-git-send-email-sbohrer@rgmadvisors.com>
	 <1380656025-8847-3-git-send-email-sbohrer@rgmadvisors.com>
	 <1380660769.19002.40.camel@edumazet-glaptop.roam.corp.google.com>
	 <20131002173422.GA7824@sbohrermbp13-local.rgmadvisors.com>
	 <1380737365.19002.110.camel@edumazet-glaptop.roam.corp.google.com>
	 <20131002203507.GB7824@sbohrermbp13-local.rgmadvisors.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, tomk@rgmadvisors.com,
	netdev <netdev@vger.kernel.org>
To: Shawn Bohrer <sbohrer@rgmadvisors.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:50553 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754359Ab3JBVIj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Oct 2013 17:08:39 -0400
Received: by mail-pd0-f172.google.com with SMTP id z10so1457438pdj.17
        for <netdev@vger.kernel.org>; Wed, 02 Oct 2013 14:08:39 -0700 (PDT)
In-Reply-To: <20131002203507.GB7824@sbohrermbp13-local.rgmadvisors.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-10-02 at 15:35 -0500, Shawn Bohrer wrote:

> Sorry, I must be a little slow today.  I understand what you are
> suggesting but I don't see how to implement it with a score.  Or at
> least not without potentially changing existing behavior.  For example
> I could make the inet->inet_daddr case add +100 to the score and I
> would know that a score >= 100 was connected.  However, this would
> unfairly favor that one case making a socket that only had a matching
> inet_daddr be better than one that only had a matching inet_dport,
> sk_bound_dev_if, and inet_rcv_saddr.
> 

If early demux has to increment a socket refcount, then decrementing it
because it found a non connected socket, this will be too expensive.

Also, keep in mind UDP chains can be long, so you should limit the early
lookup to say a single socket.

TCP ehash is mostly empty (0 or 1 socket per bucket), so early demux
really makes sense, but for UDP, there is no such property.
