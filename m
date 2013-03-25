From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next] ptp: increase the maximum number of clocks
Date: Mon, 25 Mar 2013 19:51:20 +0100
Message-ID: <20130325185120.GB3100@netboy.at.omicron.at>
References: <d219aa87bd5b3e2fa42449720d845a7110f642f0.1363893841.git.jbenc@redhat.com>
 <20130321.172017.1499060411785395307.davem@davemloft.net>
 <20130323175915.GA3036@netboy.at.omicron.at>
 <20130325170855.0194ce13@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f49.google.com ([74.125.83.49]:65420 "EHLO
	mail-ee0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933371Ab3CYSvc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Mar 2013 14:51:32 -0400
Received: by mail-ee0-f49.google.com with SMTP id d41so3350628eek.22
        for <netdev@vger.kernel.org>; Mon, 25 Mar 2013 11:51:31 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20130325170855.0194ce13@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 25, 2013 at 05:08:55PM +0100, Jiri Benc wrote:
> On Sat, 23 Mar 2013 18:59:15 +0100, Richard Cochran wrote:
> > Jiri, do you want to work on making the number of clocks essentially
> > unlimited? If not, I can take a look at this, but not right away.
> 
> I'm currently thinking of using just /dev/ptp for all PHCs in the
> system and specifying the desired network device (ifindex, likely)
> by an ioctl as the very first operation. What do you think? If this
> is viable, I can try to implement it.

While that might work for the PTP ioctls, it won't for the main
clock_gettime/settime/adjtime call. As you wrote below, these take a
dynamic clockid_t (which comes from a file descriptor), and so each
device needs its own, unique file system node.

For better or worse, we are stuck with char devs, unless we want to
redo the clock_xyz API. I certainly don't want to. We can have over a
million PTP clocks on a single major number. That should be enough.

IIRC, it is possible to grow the range of minor numbers
incrementally. Perhaps you could take a look at that?

Thanks,
Richard
 
> As for netlink, I don't see how to do that without reimplementing the
> whole kernel<->user space timer API. The API expects clockid_t which
> is either a const (a new constant wouldn't help, we can have multiple
> PHCs in the system), or a dynamic value. There is no space for more
> dynamic values as far as I can see, all combinations of the three lower
> bits are already defined. It seems we're left with file descriptors.
> 
>  Jiri
> 
> -- 
> Jiri Benc
