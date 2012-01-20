From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: Re: RFC Hanging clean-up of a namespace
Date: Fri, 20 Jan 2012 07:08:50 +0100
Message-ID: <201201200708.51684.hans.schillstrom@ericsson.com>
References: <20120119192541.GM2262734@jupiter.n2.diac24.net> <m1lip32xoi.fsf@fess.ebiederm.org> <20120119214052.GA12249@hell>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	David Miller <davem@davemloft.net>,
	"equinox@diac24.net" <equinox@diac24.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw9.se.ericsson.net ([193.180.251.57]:59078 "EHLO
	mailgw9.se.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751067Ab2ATGIz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2012 01:08:55 -0500
In-Reply-To: <20120119214052.GA12249@hell>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 19 January 2012 22:40:53 Hagen Paul Pfeifer wrote:
> * Eric W. Biederman | 2012-01-19 13:24:13 [-0800]:
> 
> >This thread is a fascinating disconnect from reality all of the way
> >around.
> >
> >- inet_twsk_purge already implements throwing out of timewait sockets
> >  when a network namespaces is being cleaned up.  So the RFC is nonsense.
> 
> This is how it is implemented, not how it should be. TIME_WAIT is not the
> problem, it is there to keep the stack from sending wrong RST messages. Maybe
> the 2*MSL could be fixed by a more accurate 2*RTT.
> 

I was only refering to my printk's i.e. the last sockets leaving the namespace was
from tcp_timer() with state 7, 2 minutes after free_nsproxy() was called.
(and assumed that was the time_wait)

> >- Keeping the timewait sockets at that point we purge them in the code
> >  can achieve nothing.  We don't have any userspace processes or network
> >  devices associated with the timewait sockets at the point we get rid
> >  of them.  The network namespace exists so long as a userspace process
> >  can find it.  The network namespace exit is asynchronous in it's own
> >  workqueue so userspace definitely is not blocked.
> 

One example of a real life problem is when a container crash where a VLAN from
a physical interface is used in the container, and you automatically reboot
that container.  A new namespace is created with that VLAN again and what happens ?
That VLAN id is busy (waiting for tcp_timer) and the continer start fails ...
So you have to wait a couple of minutes :-(

> Another possible solution could be a netns global TIME_WAIT list. But this
> is a little bit expensive and out of question - but this _is_ a convenient
> solution.
> 
> The "5 second reboot" is no argument - it show a discrepance between TCP
> requirements and the actual situation.
> 


-- 
Regards
Hans Schillstrom <hans.schillstrom@ericsson.com>
