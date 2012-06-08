From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH] bonding: Fix corrupted queue_mapping
Date: Fri, 8 Jun 2012 08:04:02 -0700
Message-ID: <CA+mtBx9xpy6Ly=3kiBc+sdHqFfsO5KRK8O=VAXTb3rofAgm2ow@mail.gmail.com>
References: <1339135057.6001.20.camel@edumazet-glaptop>
	<20120607.230216.2014005732863772019.davem@davemloft.net>
	<1339135881.6001.25.camel@edumazet-glaptop>
	<20120607.231501.463746858434969001.davem@davemloft.net>
	<1339138040.6001.39.camel@edumazet-glaptop>
	<1339140238.6001.42.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:34550 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755579Ab2FHPEE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jun 2012 11:04:04 -0400
Received: by yenm10 with SMTP id m10so1312393yen.19
        for <netdev@vger.kernel.org>; Fri, 08 Jun 2012 08:04:03 -0700 (PDT)
In-Reply-To: <1339140238.6001.42.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I must say I dont understand dev_pick_tx() anymore.
>
> It seems to ignore skb->queue_mapping (unless device provides its own
> ndo_select_queue() and this functions is aware of skb->queue_mapping, as
> correctly done in ixgbe)
>
> So commit fff3269907897ee (tcp: reflect SYN queue_mapping into SYNACK
> packets) works on ixgbe, but probably not on other multiqueue devices.
>
> This sounds like a regression to me.
>
Maybe the fundamental issue is that the queue mappings only allow for
one level of multi queue device.  It might be better if bonding didn't
have one and dev_pick_tx did the right thin (use xps on bonding
maybe).

Tom

>
>
