From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH v7] rps: Receive Packet Steering
Date: Fri, 12 Mar 2010 15:08:12 -0800
Message-ID: <65634d661003121508m3d348973k63a6ae9ca1f12f9f@mail.gmail.com>
References: <alpine.DEB.1.00.1003121210050.25665@pokey.mtv.corp.google.com>
	 <1268429319.2947.10.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:6467 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933282Ab0CLXIP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Mar 2010 18:08:15 -0500
Received: from kpbe18.cbf.corp.google.com (kpbe18.cbf.corp.google.com [172.25.105.82])
	by smtp-out.google.com with ESMTP id o2CN8EFx017983
	for <netdev@vger.kernel.org>; Fri, 12 Mar 2010 15:08:14 -0800
Received: from fg-out-1718.google.com (fgae21.prod.google.com [10.86.56.21])
	by kpbe18.cbf.corp.google.com with ESMTP id o2CN8CsG022303
	for <netdev@vger.kernel.org>; Fri, 12 Mar 2010 15:08:13 -0800
Received: by fg-out-1718.google.com with SMTP id e21so556753fga.0
        for <netdev@vger.kernel.org>; Fri, 12 Mar 2010 15:08:12 -0800 (PST)
In-Reply-To: <1268429319.2947.10.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> One last point about placement of rxhash in struct sk_buff, that I
> missed in my previous review, sorry...
>
> You put it right before cb[48] which is now aligned to 8 bytes (since
> commit da3f5cf1 skbuff: align sk_buff::cb to 64 bit and close some
> potential holes), so this adds a 4 bytes hole.
>
> Please put it elsewhere, possibly close to fields that are read in
> get_rps_cpu() (skb->queue_mapping, skb->protocol, skb->data, ...) to
> minimize number of cache lines that dispatcher cpu has to bring into its
> cache, before giving skb to another cpu for IP/TCP processing.
>
Looks like it will fit right before queue_mapping, I'll put it there.

Tom
