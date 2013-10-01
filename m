From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next 2/3] udp: Add udp early demux
Date: Tue, 01 Oct 2013 13:52:49 -0700
Message-ID: <1380660769.19002.40.camel@edumazet-glaptop.roam.corp.google.com>
References: <1380656025-8847-1-git-send-email-sbohrer@rgmadvisors.com>
	 <1380656025-8847-3-git-send-email-sbohrer@rgmadvisors.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, tomk@rgmadvisors.com,
	netdev <netdev@vger.kernel.org>
To: Shawn Bohrer <sbohrer@rgmadvisors.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f45.google.com ([209.85.160.45]:39364 "EHLO
	mail-pb0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751361Ab3JAUwv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Oct 2013 16:52:51 -0400
Received: by mail-pb0-f45.google.com with SMTP id mc17so7658391pbc.32
        for <netdev@vger.kernel.org>; Tue, 01 Oct 2013 13:52:50 -0700 (PDT)
In-Reply-To: <1380656025-8847-3-git-send-email-sbohrer@rgmadvisors.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-10-01 at 14:33 -0500, Shawn Bohrer wrote:
> The removal of the routing cache introduced a performance regression for
> some UDP workloads since a dst lookup must be done for each packet.
> This change caches the dst per socket in a similar manner to what we do
> for TCP by implementing early_demux.
> 
> For UDP multicast we can only cache the dst if there is only one
> receiving socket on the host.  Since caching only works when there is
> one receiving socket we do the multicast socket lookup using RCU.

For unicast, we should find a matching socket for early demux only if
this is a connected socket.

Otherwise, forwarding setups will break.

You probably need to add a minimum score to __udp4_lib_lookup()
