From: Kevin Groeneveld <kgroeneveld@gmail.com>
Subject: Re: [PATCH] b44: add 64 bit stats
Date: Fri, 20 Jul 2012 22:22:40 -0400
Message-ID: <CABF+-6XGO0Qvqd1O-aY28kG1jV=L6eRcupnZpaimTunddPwL2A@mail.gmail.com>
References: <CABF+-6XaYk8qXnFNXF_+rQ144jyDFgFqDVKsuZv+S_0VZxBAvw@mail.gmail.com>
	<1342337165.3265.10640.camel@edumazet-glaptop>
	<CABF+-6XVCTDZedzcp-gWACYpG9NLmZUdwW2zsXC8WNKWk3dE5w@mail.gmail.com>
	<1342759989.2626.5472.camel@edumazet-glaptop>
	<1342761865.2626.5572.camel@edumazet-glaptop>
	<CABF+-6Ubh6rSYV=L8-QV466XNo5OqCxA+4DRqXGdELhnSPkPZQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f46.google.com ([209.85.212.46]:41538 "EHLO
	mail-vb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753675Ab2GUCWl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jul 2012 22:22:41 -0400
Received: by vbbff1 with SMTP id ff1so3441357vbb.19
        for <netdev@vger.kernel.org>; Fri, 20 Jul 2012 19:22:40 -0700 (PDT)
In-Reply-To: <CABF+-6Ubh6rSYV=L8-QV466XNo5OqCxA+4DRqXGdELhnSPkPZQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 20, 2012 at 2:56 PM, Kevin Groeneveld <kgroeneveld@gmail.com> wrote:
>> In fact all network drivers should use the _bh version.
>> Could you send a patch for all of them, based on net-next tree ?
>
> Sure, I can work on that.  It should be a relatively easy thing to
> update.  I can probably send a patch within the next couple days.

As I have been working on the patch I have been trying convince myself
that each case I change actually needs the _bh version of the
functions instead of blindly changing them.  So far I have found the
following where the change seems to make sense:

drivers/net/dummy.c
drivers/net/ethernet/neterion/vxge/vxge-main.c
drivers/net/loopback.c
drivers/net/virtio_net.c
net/bridge/br_device.c

The only two other places in the networking code that use
u64_stats_fetch_begin/u64_stats_fetch_retry are:

net/l2tp/l2tp_netlink.c
net/netfilter/ipvs/ip_vs_est.c

Do these need to be updated as well?  Looking at these files quickly
and with my limited knowledge of the kernel I am not sure if they
update the stats in a BH context or not.


Kevin
