From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Heavy spin_lock contention in __udp4_lib_mcast_deliver increase
Date: Thu, 26 Apr 2012 18:31:28 +0200
Message-ID: <1335457888.2775.55.camel@edumazet-glaptop>
References: <20120426151527.GA2479@BohrerMBP.rgmadvisors.com>
	 <1335455595.2775.47.camel@edumazet-glaptop>
	 <20120426162819.GD2479@BohrerMBP.rgmadvisors.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Shawn Bohrer <sbohrer@rgmadvisors.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:59891 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758327Ab2DZQbg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2012 12:31:36 -0400
Received: by eaaq12 with SMTP id q12so395717eaa.19
        for <netdev@vger.kernel.org>; Thu, 26 Apr 2012 09:31:35 -0700 (PDT)
In-Reply-To: <20120426162819.GD2479@BohrerMBP.rgmadvisors.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-04-26 at 11:28 -0500, Shawn Bohrer wrote:

> No in this case it is 300 unique multicast addresses, and there is one
> socket listening to each multicast address.  So a single message is
> only copied once to a single socket.  The bottle neck appears to be
> that even though a single message is only going to get copied to a
> single socket we still have to walk the list of all 300 sockets while
> holding the spin lock to figure that out.  The incoming packet rate is
> also roughly evenly distributed across all 300 multicast addresses so
> even though we have multiple receive queues they are all contending
> for the same spin lock.
> 

I repeat my question : Are these 300 sockets bound to the same UDP
port ?

If not, they should be spreaded in hash table.

You can make this hash table very big to reduce hash collisions

Boot parameter : uhash_entries=65536
