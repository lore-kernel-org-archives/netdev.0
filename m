From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [BUG net-next] infamous dev refcnt leak... again.
Date: Fri, 14 Aug 2015 17:26:45 -0700
Message-ID: <1439598405.31334.6.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1439586894.7507.5.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1439594063.7507.11.camel@edumazet-glaptop2.roam.corp.google.com>
	 <55CE7776.5000706@cumulusnetworks.com>
	 <1439595092.7507.14.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:35563 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751172AbbHOA0s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Aug 2015 20:26:48 -0400
Received: by pacgr6 with SMTP id gr6so69324430pac.2
        for <netdev@vger.kernel.org>; Fri, 14 Aug 2015 17:26:48 -0700 (PDT)
In-Reply-To: <1439595092.7507.14.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-08-14 at 16:31 -0700, Eric Dumazet wrote:

> 
> I simply reboot my host. eth0 device can not be dismantled and block the
> reboot, I gave to reset the host.
> 
> I get the issue every time.
> 
> I confirm reverting 3bfd847203c6d89532f836ad3f5b4ff4ced26dd9
> removes the issue for me.
> 

Also, netif_index_is_vrf() is supposed to be called under rcu,
but it is not the case from net/ipv4/udp.c , and ip_route_connect_init()
