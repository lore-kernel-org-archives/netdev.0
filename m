From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/2] net: Expose header length compution
 function
Date: Sat, 10 May 2014 10:49:57 -0700
Message-ID: <1399744197.7973.11.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1399553434-25617-1-git-send-email-amirv@mellanox.com>
		<1399553434-25617-2-git-send-email-amirv@mellanox.com>
	 <20140509.162454.1317479460010270185.davem@davemloft.net>
	 <536E5DF4.8010908@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, amirv@mellanox.com,
	netdev@vger.kernel.org, idos@mellanox.com,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	bruce.w.allan@intel.com, carolyn.wyborny@intel.com,
	donald.c.skidmore@intel.com, gregory.v.rose@intel.com,
	alexander.h.duyck@intel.com, john.ronciak@intel.com,
	mitch.a.williams@intel.com, yevgenyp@mellanox.com,
	ogerlitz@mellanox.com
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:63574 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751001AbaEJRuA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 May 2014 13:50:00 -0400
Received: by mail-pd0-f173.google.com with SMTP id y10so4952507pdj.18
        for <netdev@vger.kernel.org>; Sat, 10 May 2014 10:50:00 -0700 (PDT)
In-Reply-To: <536E5DF4.8010908@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2014-05-10 at 10:12 -0700, Alexander Duyck wrote:

> Actually the flow keys with the exception of maybe thoff and ip_proto
> are pretty much useless to us for our purpose.  As is we are left to
> then go off and compute the header length of the transport before we get
> to the information we need.
> 
> The two functions are very similar though.  It might be worth while to
> actually park the two next to each other so that it is obvious that when
> one gets updated to support a new protocol the other should as well.  So
> for example the headlen function could pick up some of the tunnel stuff.
> 
> The main difference between __net_get_headlen() and skb_flow_dissect()
> is that skb_flow_dissect is meant to work on a packet headed in either
> direction, as such there are multiple calls to skb_copy_bits and all the
> copies out of the paged area that go with it.  __net_get_headlen() is
> meant to be called by the base netdev on a linear buffer to parse
> through everything from the start of the Ethernet header to the start of
> the data section and determine the length of that region.  So one
> obvious difference is that we care about the length of non-l4 headers,
> whereas skb_flow_dissect does not.

Its actually possible to prepare an skb with the needed parts so that
skb_flow_dissect() has no copy to do.

Its a 10 lines helper maybe.

I already mentioned this in the past, I fail to understand your
resistance.

I will provide it unless someone beats me, because its the week end and
I have other plans at the moment.
