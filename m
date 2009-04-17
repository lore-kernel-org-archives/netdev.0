From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: PATCH: Multicast: Filter multicast traffic per socket mc_list
Date: Fri, 17 Apr 2009 14:31:33 -0700
Message-ID: <OFDADDACF0.D592E966-ON8825759B.0073E304-8825759B.00763DF6@us.ibm.com>
References: <alpine.DEB.1.10.0904170952050.11877@qirst.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org, nhorman@tuxdriver.com,
	vladislav.yasevich@hp.com
To: Christoph Lameter <cl@linux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e37.co.us.ibm.com ([32.97.110.158]:39807 "EHLO
	e37.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750944AbZDQVbj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Apr 2009 17:31:39 -0400
In-Reply-To: <alpine.DEB.1.10.0904170952050.11877@qirst.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netdev-owner@vger.kernel.org wrote on 04/17/2009 06:56:04 AM:

> On Thu, 16 Apr 2009, David Miller wrote:
> 
> > No Christoph, do this right.
> >
>    > Linux by default will behave the way it has for 15+ years.  And if 
an
> > application wants new behavior, you have to ask for it.
> >
> > End of story.
> 
> This is not right. All other OSes filter multicast traffic according to
> the multicast groups subscribed too (and that includes the evil one).

        This is not true.

> There is no requirement of asking for "new" behavior. Why should 
multicast
> applications have to add special code to request something that comes by
> default on other platforms?

        Linux is not Solaris. I think Solaris is wrong to change the
behavior from the original BSD behavior, but it should be no surprise
that there are other differences in the API's, too. It's not difficult
to write code that works as intended on both, and the case Solaris is
trying to avoid is not really avoided since you can still receive
unicast traffic, or totally unrelated multicast traffic on the shared
port and multicast address space. If the app doesn't use the port to
distinguish it, it simply should bind the multicast address it wants,
use PKTINFO, SO_BINDTODEVICE or the like as well. In your case, multiple
sockets or filtering based on the "to" address are possibilties that
work on Solaris too, and fix more unintended traffic problems than
just a different group.
        A per-socket option is a more trivial way to do this, but
turning it on for sockets that want the existing, intended and
long-standing behavior is obviously wrong.

                                                                +-DLS

