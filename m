From: Bill Fink <billfink@mindspring.com>
Subject: Re: can TCP socket send buffer be over used?
Date: Wed, 4 Aug 2010 03:20:18 -0400
Message-ID: <20100804032018.19fd9a36.billfink@mindspring.com>
References: <AANLkTi=Ma2yMVbgRnUUB6T1j=rHLb60oAXqCSbM35KgT@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jack Zhang <jack.zhang2011@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-spurfowl.atl.sa.earthlink.net ([209.86.89.66]:60221
	"EHLO elasmtp-spurfowl.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755980Ab0HDHUT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Aug 2010 03:20:19 -0400
In-Reply-To: <AANLkTi=Ma2yMVbgRnUUB6T1j=rHLb60oAXqCSbM35KgT@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 3 Aug 2010, Jack Zhang wrote:

> Hi there,
> 
> I'm doing experiments with (modified*) software iSCSI over a link with
> an emulated Round-Trip Time (RTT) of 100 ms by netem.
> 
> For example, when I set the send buffer size to 128 KB, i could get a
> throughput up to 43 Mbps, which seems to be impossible as the (buffer
> size) / RTT is only 10 Mbps.

I'm not sure what's going on with this first case.

> And When I set the send buffer size to 512 KB, i can get a throughput
> up to 60 Mbps, which also seems to be impossible as the (buffer size)
> / RTT is only 40 Mbps.

But this case seems just about right.  Linux doubles the requested
buffer size, then uses one quarter of that for overhead (not half),
so you effectively get 50% more than requested (2X * 3/4 = 1.5X).
Plugging your case into bc:

wizin% bc
scale=10
512*1024*8/0.100/10^6*3/2
62.9145600000

						-Bill



> I understand that when the buffer size is set to 128 KB, I actually
> got a buffer of 256 KB as the kernel doubles the buffer size. I also
> understand that half the doubled buffer size is used for meta data
> instead of the actual data to be transferred. So basically the
> effective buffer sizes for the two examples  are just 128 KB and 512
> KB respectively.
> 
> So I was confused because, theoretically, send buffers of 128 KB and
> 512 KB should achieve no more than 10 Mbps and 40 Mbps respectively
> but I was able to get way much more than the theoretical limit. So
> I was wondering is there any chance the send buffer can be "overused"?
> or there is some other mechanism inside TCP is doing some
> optimization?
> 
> * the modification is to disable "TCP_NODELAY" , enable
> "use_clustering" for SCSI, and set different send buffer sizes for the
> TCP socket buffer.
> 
> Any idea will be highly appreciated.
> 
> Thanks a lot!
