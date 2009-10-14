From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: Re: [PATCH] Add sk_mark route lookup support for IPv4 listening
	sockets, and for IPv4 multicast forwarding
Date: Wed, 14 Oct 2009 00:51:56 -0700
Message-ID: <55a4f86e0910140051v69441b09gd364b32f8e2d0c68@mail.gmail.com>
References: <200910071559.56526.atis@mikrotik.com>
	 <20091007.135627.96995518.davem@davemloft.net>
	 <55a4f86e0910071703i4735f1aan1ddba81eec7eef19@mail.gmail.com>
	 <20091007.223928.34412707.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: atis@mikrotik.com, netdev@vger.kernel.org, panther@balabit.hu,
	eric.dumazet@gmail.com, brian.haley@hp.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f227.google.com ([209.85.220.227]:45620 "EHLO
	mail-fx0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757245AbZJNHwe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Oct 2009 03:52:34 -0400
Received: by fxm27 with SMTP id 27so11209890fxm.17
        for <netdev@vger.kernel.org>; Wed, 14 Oct 2009 00:51:56 -0700 (PDT)
In-Reply-To: <20091007.223928.34412707.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm thinking that the mark should be a tunnel parameter with values of
inherit or a constant.

The reasoning being that this allows you to mark all packets leaving
on a tunnel with a specific value and you can then use that mark to
use a different routing table just for that tunnel.

The default routing table could point at the tunnel, and if the tunnel
is marked than the mark on those packets could make them not use the
default routing table, and instead use a routing table which is closer
to physical network layout.

I believe nowadays you usually solve this by having an explicit route
for the other endpoint of the tunnel in the main routing table...
which means you can't actually tunnel the normal traffic directed at
the other endpoint of the tunnel.
This would fix that.
