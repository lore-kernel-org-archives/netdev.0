From: Vijay Subramanian <subramanian.vijay@gmail.com>
Subject: Re: TCP and reordering
Date: Wed, 28 Nov 2012 00:35:56 -0800
Message-ID: <CAGK4HS_GVZqoGVjd87N6skM-SBWyPtY-AhiR9FDcR8ty5x6Xbg@mail.gmail.com>
References: <CAAeewD8zsfb6QPFecvPab_oK3D3T7eG_M53MVvfJ2QrxUFxWSQ@mail.gmail.com>
	<50B4F2DA.8020206@hp.com>
	<CAAeewD9MtEx4uF6ezbBj7Ci5OzX8VK7p=WQ2TB3PfjmznA4X0w@mail.gmail.com>
	<20121127.210611.1127622873924794001.davem@davemloft.net>
	<20121128072611.GA26010@pob.ytti.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, rick.jones2@hp.com,
	netdev@vger.kernel.org
To: Saku Ytti <saku@ytti.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:42369 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752798Ab2K1If4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Nov 2012 03:35:56 -0500
Received: by mail-ob0-f174.google.com with SMTP id wc20so11778552obb.19
        for <netdev@vger.kernel.org>; Wed, 28 Nov 2012 00:35:56 -0800 (PST)
In-Reply-To: <20121128072611.GA26010@pob.ytti.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>
> My proposal (or question more accurately) was to add 'reorder' counter to
> sockets, which would increment when duplicate ACK is followed by same
> sequence twice.
> Then you could automatically/dynamically delay duplicate acks, as you'd
> start to expect to receive the frames, out-of-order. Giving non-lossy
> reordering links pretty much 100% same performance as non-lossy in-order
> links.

RFC 5681 says that out-of-order packets should be acked immediately.
Please see section 4.2 for detailed reasoning.
It also explains why acks should not be delayed too much.

Also note that reordering is tracked on the sender side using the per
flow variable tp->reordering . This measures the amount of reordering
on the connection so that
fast retransmit and other loss recovery mechanisms are not entered
prematurely. Doesn't this behavior at the  sender already provide the
behavior you seek?

Regards,
Vijay
