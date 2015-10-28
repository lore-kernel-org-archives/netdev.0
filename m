From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [BUG] Erroneous behavior in try_to_coalesce
Date: Wed, 28 Oct 2015 13:04:59 -0700
Message-ID: <1446062699.7476.77.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAJFSNy4ar_=QP-zYi_AmEZ_70JOgOiqELBdWWQ=AZy=2Faxf5Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@redhat.com, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org,
	SiteGround Operations <operations@siteground.com>
To: Nikolay Borisov <kernel@kyup.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:35656 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750927AbbJ1UFC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Oct 2015 16:05:02 -0400
Received: by pasz6 with SMTP id z6so16193108pas.2
        for <netdev@vger.kernel.org>; Wed, 28 Oct 2015 13:05:01 -0700 (PDT)
In-Reply-To: <CAJFSNy4ar_=QP-zYi_AmEZ_70JOgOiqELBdWWQ=AZy=2Faxf5Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-10-29 at 04:19 +0900, Nikolay Borisov wrote:

> 
> 
> Could you please comment whether it looks viable so that I can resend
> as a proper fix? Also the interesting question is what kind of packets
> could trigger this warn_on_once? In both traces ovs_packet_cmd_execute
> is present so I suspect it might be possible that somehow openvswitch is
> injecting wrong packets which make the kernel crash.

Bug is the packet producer, not in try_to_coalesce()

This issue comes up on netdev from times to times...

The WARN_ON() in try_to_coalesce() is an attempt to detect a producer
made a lie about truesize, leading to OOM in case of abuses.

Do not paper over the bug, find the root cause and fix it, thanks.
