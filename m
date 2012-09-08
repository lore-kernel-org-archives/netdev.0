From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: small bug on rxhash calculation
Date: Sat, 08 Sep 2012 10:18:40 +0200
Message-ID: <1347092320.1234.335.camel@edumazet-glaptop>
References: <20120907.125748.25526531079163699.davem@davemloft.net>
	 <1347061251-2019-1-git-send-email-chema@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, edumazet@google.com,
	netdev@vger.kernel.org, Chema Gonzalez <chema@berkeley.edu>
To: Chema Gonzalez <chema@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:49236 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751917Ab2IHISp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Sep 2012 04:18:45 -0400
Received: by eaac11 with SMTP id c11so138452eaa.19
        for <netdev@vger.kernel.org>; Sat, 08 Sep 2012 01:18:44 -0700 (PDT)
In-Reply-To: <1347061251-2019-1-git-send-email-chema@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-09-07 at 16:40 -0700, Chema Gonzalez wrote:
> In the current rxhash calculation function, while the
> sorting of the ports/addrs is coherent (you get the
> same rxhash for packets sharing the same 4-tuple, in
> both directions), ports and addrs are sorted
> independently. This implies packets from a connection
> between the same addresses but crossed ports hash to
> the same rxhash.
> 
> For example, traffic between A=S:l and B=L:s is hashed
> (in both directions) from {L, S, {s, l}}. The same
> rxhash is obtained for packets between C=S:s and D=L:l.
> 
> This patch ensures that you either swap both addrs and ports,
> or you swap none. Traffic between A and B, and traffic
> between C and D, get their rxhash from different sources
> ({L, S, {l, s}} for A<->B, and {L, S, {s, l}} for C<->D)
> 
> The patch is co-written with Eric Dumazet <edumazet@google.com>
> 
> Signed-off-by: Chema Gonzalez <chema@google.com>
> ---

Signed-off-by: Eric Dumazet <edumazet@google.com>
