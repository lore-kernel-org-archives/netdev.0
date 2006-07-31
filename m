From: Brent Cook <bcook@bpointsys.com>
Subject: Re: [RFC 1/4] kevent: core files.
Date: Mon, 31 Jul 2006 17:16:48 -0500
Message-ID: <200607311716.48455.bcook@bpointsys.com>
References: <44CB8A67.3060801@redhat.com> <20060731194143.GA12569@2ka.mipt.ru> <20060731.150028.26276495.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: johnpol@2ka.mipt.ru, drepper@redhat.com, zach.brown@oracle.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 70-253-197-251.ded.swbell.net ([70.253.197.251]:39451 "EHLO
	bpointsys.com") by vger.kernel.org with ESMTP id S1751404AbWGaWQk
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Jul 2006 18:16:40 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060731.150028.26276495.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 31 July 2006 17:00, David Miller wrote:
>
> So we'd have cases like this, assume we start with a full event
> queue:
>
> 	thread A		thread B
>
> 	dequeue event
> 	aha, new connection
> 	accept()
> 				register new kevent
> 				queue is now full again
> 	add kevent on new
> 	connection
>
> At this point thread A doesn't have very many options when the kevent
> add fails.  You cannot force this thread to read more events, since he
> may not be in a state where he is easily able to do so.

There has to be some thread that is responsible for reading events. Perhaps a 
reasonable thing for a blocked thread that cannot process events to do is to 
yield to one that can?

