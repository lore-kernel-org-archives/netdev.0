From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net PATCH] flow_dissector: Fix unaligned access in
 __skb_flow_dissector when used by eth_get_headlen
Date: Sat, 30 Jan 2016 11:26:51 -0800
Message-ID: <1454182011.7627.141.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20160129180651.GA17127@oracle.com>
	 <20160130024556.6227.51798.stgit@localhost.localdomain>
	 <1454124234.7627.119.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20160130161702.GA11601@oracle.com>
	 <CAKgT0UcZAh+ciNMkJDdnp7E0xyGMhvgSzJLwORLqYXbpABtoRQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Sowmini Varadhan <sowmini.varadhan@oracle.com>,
	Alexander Duyck <aduyck@mirantis.com>,
	Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Tom Herbert <tom@herbertland.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:36809 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751260AbcA3T0x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Jan 2016 14:26:53 -0500
Received: by mail-pa0-f41.google.com with SMTP id yy13so58985821pab.3
        for <netdev@vger.kernel.org>; Sat, 30 Jan 2016 11:26:53 -0800 (PST)
In-Reply-To: <CAKgT0UcZAh+ciNMkJDdnp7E0xyGMhvgSzJLwORLqYXbpABtoRQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2016-01-30 at 10:36 -0800, Alexander Duyck wrote:

> As far as the NET_IP_ALIGN on the page offset I think it is a horrible
> idea.  Basically it means we have to allocate at least 1K more space
> than we need since page sizes are powers of 2, and buffer sizes in
> hardware are measured in 1K increments.

I thought Ethernet frames were something like ~1500 bytes.

Can't you program the NIC to not receive frames bigger than MTU + 18, or
at least 2046 ?

Of course, if the NIC is able to push 2048 bytes (instead of 2046 max),
using an offset of 2 is not going to work.
