From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [RFC] New driver API to speed up small packets xmits
Date: Fri, 11 May 2007 10:34:22 +0530
Message-ID: <OFC32212EC.5585A74E-ON652572D8.001B86BB-652572D8.001BDDAD@in.ibm.com>
References: <5640c7e00705101159w68750a47xc06495e4395de583@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: "Evgeniy Polyakov" <johnpol@2ka.mipt.ru>, netdev@vger.kernel.org,
	"Rick Jones" <rick.jones2@hp.com>,
	"Vlad Yasevich" <vladislav.yasevich@hp.com>
To: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausmtp04.au.ibm.com ([202.81.18.152]:35904 "EHLO
	ausmtp04.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754252AbXEKFF0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 May 2007 01:05:26 -0400
Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by ausmtp04.au.ibm.com (8.13.8/8.13.8) with ESMTP id l4B5PAa7049476
	for <netdev@vger.kernel.org>; Fri, 11 May 2007 15:25:10 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.250.244])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l4B58sMZ165748
	for <netdev@vger.kernel.org>; Fri, 11 May 2007 15:08:54 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l4B55Klo018924
	for <netdev@vger.kernel.org>; Fri, 11 May 2007 15:05:22 +1000
In-Reply-To: <5640c7e00705101159w68750a47xc06495e4395de583@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"Ian McDonald" <ian.mcdonald@jandi.co.nz> wrote on 05/11/2007 12:29:08 AM:

>
> As I see this proposed patch it is about reducing the number of "task
> switches" between the driver and the protocol. I use task switch in
> speech marks as it isn't really as is in the kernel. So in other words
> we are hoping that spending more time in each area would keep the
> cache hot and work to be done if locks held. This of course requires
> that the complexity added doesn't outweigh the gains - otherwise you
> could end up in a worse scenario where the driver doesn't send packets
> because the protocol is busy linking them.

This is a right summary.

> As far as I can tell you're not combining packets?? This would
> definitely break UDP/DCCP which are datagram based.

Not combining packets, I am sending them out in the same sequence it was
queued. If the xmit failed, the driver's new API returns the skb which
failed to be sent. This skb and all other linked skbs are requeue'd in
the reverse order (fofi?) till the next time it is tried again. I see
that sometimes I can send tx_queue_len packets in one shot and all
succeeds. But the downside is that in failure case, the packets have to
be requeue'd.

> Will be interesting to see results but I'm a little sceptical.

I was just going to test, and Rick helpfully pointed out netperf4.

Thanks,

- KK

>
> --
> Web: http://wand.net.nz/~iam4/
> Blog: http://iansblog.jandi.co.nz
> WAND Network Research Group

