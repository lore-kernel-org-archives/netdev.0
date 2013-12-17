From: Michal Schmidt <mschmidt@redhat.com>
Subject: Re: [PATCH] ipv6: sit: update mtu check to take care of gso packets
Date: Tue, 17 Dec 2013 15:22:37 +0100
Message-ID: <52B05E2D.6060001@redhat.com>
References: <52AB322B.7030802@redhat.com> <1387204283.19078.240.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:20899 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752958Ab3LQOWn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Dec 2013 09:22:43 -0500
In-Reply-To: <1387204283.19078.240.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/16/2013 03:31 PM, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> While testing my changes for TSO support in SIT devices,
> I was using sit0 tunnel which appears to include nopmtudisc flag.
> 
> But using :
> 
> ip tun add sittun mode sit remote $REMOTE_IPV4 local $LOCAL_IPV4 \
>    dev $IFACE
> 
> We get a tunnel which rejects too long packets because of the mtu check
> which is not yet GSO aware.
> 
> erd:~# ip tunnel
> sittun: ipv6/ip  remote 10.246.17.84  local 10.246.17.83  ttl inherit  6rd-prefix 2002::/16 
> sit0: ipv6/ip  remote any  local any  ttl 64  nopmtudisc 6rd-prefix 2002::/16 
> 
> This patch is based on an excellent report from
> Michal Shmidt.
> 
> In the future, we probably want to extend the MTU check to do the
> right thing for GSO packets...
> 
> Fixes: ("61c1db7fae21 ipv6: sit: add GSO/TSO support")
> Reported-by: Michal Schmidt <mschmidt@redhat.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Tested-by: Michal Schmidt <mschmidt@redhat.com>

It works fine now. Thanks.
Michal
