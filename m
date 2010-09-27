From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH v3] xmit_compl_seq: information to reclaim vmsplice buffers
Date: Mon, 27 Sep 2010 11:38:36 -0700
Message-ID: <AANLkTimdrFuYONq6FvBW41AnhpA6Q+acSUmy4CiJatYL@mail.gmail.com>
References: <alpine.DEB.1.00.1009231426450.11579@pokey.mtv.corp.google.com>
	<20100927172315.GA8387@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, davem@davemloft.net, sridharr@google.com
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.35]:52052 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933309Ab0I0Sij (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Sep 2010 14:38:39 -0400
Received: from kpbe14.cbf.corp.google.com (kpbe14.cbf.corp.google.com [172.25.105.78])
	by smtp-out.google.com with ESMTP id o8RIcb0v024065
	for <netdev@vger.kernel.org>; Mon, 27 Sep 2010 11:38:38 -0700
Received: from pvg16 (pvg16.prod.google.com [10.241.210.144])
	by kpbe14.cbf.corp.google.com with ESMTP id o8RIcAWS010779
	for <netdev@vger.kernel.org>; Mon, 27 Sep 2010 11:38:36 -0700
Received: by pvg16 with SMTP id 16so1497489pvg.12
        for <netdev@vger.kernel.org>; Mon, 27 Sep 2010 11:38:36 -0700 (PDT)
In-Reply-To: <20100927172315.GA8387@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>
> Can not packets referencing this memory
> still be outstanding at the NIC device, if retransmit happens
> before the ack but after the packet was passed to a device?
>
> It's true that the reftransmit will likely get discarded
> by the remote end, but this might be a security issue
> if an application puts sensitive data in the buffer
> and that gets inadvertently sent on the wire, can it not?
>
Yes, this hole probably does exist.  I don't know how to fix it other
than more API that specifically reports when all references to a
buffer are released.  In the case of TCP that probably means we'd need
a destructor.

> --
> MST
>
