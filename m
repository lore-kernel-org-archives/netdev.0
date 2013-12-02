From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] net: sched: tbf: fix calculation of max_size
Date: Mon, 2 Dec 2013 10:29:23 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B7452@saturn3.aculab.com>
References: <5292C76E.1070701@huawei.com><52933CC7.9070805@huawei.com><AE90C24D6B3A694183C094C60CF0A2F6026B7443@saturn3.aculab.com> <20131201.201110.1947727947032213373.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: <yangyingliang@huawei.com>, <eric.dumazet@gmail.com>,
	<netdev@vger.kernel.org>, <brouer@redhat.com>, <jpirko@redhat.com>,
	<jbrouer@redhat.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:50654 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1753071Ab3LBKbk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Dec 2013 05:31:40 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 14176-03 for <netdev@vger.kernel.org>;
 Mon,  2 Dec 2013 10:31:32 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <20131201.201110.1947727947032213373.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org] On Behalf Of David Miller
> Sent: 02 December 2013 01:11
> To: David Laight
> Cc: yangyingliang@huawei.com; eric.dumazet@gmail.com; netdev@vger.kernel.org; brouer@redhat.com;
> jpirko@redhat.com; jbrouer@redhat.com
> Subject: Re: [PATCH] net: sched: tbf: fix calculation of max_size
> 
> From: "David Laight" <David.Laight@ACULAB.COM>
> Date: Mon, 25 Nov 2013 12:22:30 -0000
> 
> >> From: Yang Yingliang <yangyingliang@huawei.com>
> >>
> >> Current max_size is caluated from rate table. Now, the rate table
> >> has been replaced and it's wrong to caculate max_size based on this
> >> rate table. It can lead wrong calculation of max_size.
> >>
> >> The burst in kernel may be lower than user asked, because burst may gets
> >> some loss when transform it to buffer(E.g. "burst 40kb rate 30mbit/s")
> >> and it seems we cannot avoid this loss. And burst's value(max_size) based
> >> on rate table may be equal user asked. If a packet's length is max_size,
> >> this packet will be stalled in tbf_dequeue() because its length is above
> >> the burst in kernel so that it cannot get enough tokens. The max_size guards
> >> against enqueuing packet sizes above q->buffer "time" in tbf_enqueue().
> >
> > Why not adjust the calculations so that the number of allocated tokens
> > can go negative?
> >
> > So allow the transfer if the number of tokens is +ve and then subtract
> > the number needed for the message itself.
> >
> > I think this would change the semantics of the configured 'burst' value
> > very slightly (to 'at least' from 'at most') but the average would still
> > be correct.
> >
> > FWIW I've done similar rate limiters that run directly in units of 'time'.
> > The fact that system time advances automatically generates credit.
> 
> Yang has responded to your concerns, are they addressed?

I was mostly making some suggestions that might have made fixing it easier.
So I'm not really worried.

	David
