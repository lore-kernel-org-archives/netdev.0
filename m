From: jamal <hadi@cyberus.ca>
Subject: Re: Patch resubmission: RFC2863 operstatus for 2.5.49
Date: Wed, 4 Dec 2002 08:06:07 -0500 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.GSO.4.30.0212040753410.2731-100000@shell.cyberus.ca>
References: <3DED3869.5E47D7A2@isg.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: <davem@redhat.com>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Stefan Rompf <srompf@isg.de>
In-Reply-To: <3DED3869.5E47D7A2@isg.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



On Wed, 4 Dec 2002, Stefan Rompf wrote:

> Hi Jamal,
>
> > Just thought of something, it may be a little tricky but valuable and
> > i am not quiet sure if it should part of your patch: We probably need to
> > flush the qdiscs software queues; maybe even the DMA ring i.e simulate
> > admin down followed by admin up.
>
> dev_close() is doing quite a lot of stuff, so we should do nothing more
> than flush the qdiscs when the link comes up. But is it really useful?

Indeed it is, infact i have been bitten by buffered packets confusing
an upstream switch with buffered VRRP packets when someone stepped on a
cable that i later reconnected. Typically about 30 seconds
later an arp fixes the problem - if the queue had been properly flushed
thered be no problem.
I think maybe flushing all routes and neighbors pointing out that
device is also useful.

> Normally, the queues are short anyway to keep latencies low, and fifty
> additional packets don't hurt. I rather think about clearing neighbor
> tables and the route cache whenever the operstatus goes down.
>
> Anyway, implementation and usage of the notification should not mix up,
> so it let it be a separate patch.

Agreed; just queueing more work for you ;->

cheers,
jamal
