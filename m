From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH v3 0/2] sctp: delay calls to sk_data_ready() as much as
 possible
Date: Thu, 14 Apr 2016 09:03:24 -0400
Message-ID: <20160414130324.GA6806@hmsreliant.think-freely.org>
References: <cover.1460144373.git.marcelo.leitner@gmail.com>
 <20160413.230532.676746231426161126.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: marcelo.leitner@gmail.com, netdev@vger.kernel.org,
	vyasevich@gmail.com, linux-sctp@vger.kernel.org,
	David.Laight@ACULAB.COM, jkbs@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:46274 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755182AbcDNNDo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2016 09:03:44 -0400
Content-Disposition: inline
In-Reply-To: <20160413.230532.676746231426161126.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 13, 2016 at 11:05:32PM -0400, David Miller wrote:
> From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
> Date: Fri,  8 Apr 2016 16:41:26 -0300
> 
> > 1st patch is a preparation for the 2nd. The idea is to not call
> > ->sk_data_ready() for every data chunk processed while processing
> > packets but only once before releasing the socket.
> > 
> > v2: patchset re-checked, small changelog fixes
> > v3: on patch 2, make use of local vars to make it more readable
> 
> Applied to net-next, but isn't this reduced overhead coming at the
> expense of latency?  What if that lower latency is important to the
> application and/or consumer?
Thats a fair point, but I'd make the counter argument that, as it currently
stands, any latency introduced (or removed), is an artifact of our
implementation rather than a designed feature of it.  That is to say, we make no
guarantees at the application level regarding how long it takes to signal data
readines from the time we get data off the wire, so I would rather see our
throughput raised if we can, as thats been sctp's more pressing achilles heel.


Thats not to say I'd like to enable lower latency, but I'd rather have this now,
and start pondering how to design that in.  Perhaps we can convert the pending
flag to a counter to count the number of events we enqueue, and call
sk_data_ready every  time we reach a sysctl defined threshold.

Neil

> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
