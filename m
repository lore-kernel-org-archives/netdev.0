From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: RFC Hanging clean-up of a namespace
Date: Thu, 19 Jan 2012 22:40:53 +0100
Message-ID: <20120119214052.GA12249@hell>
References: <20120119192541.GM2262734@jupiter.n2.diac24.net>
 <20120119.143105.735366189369504929.davem@davemloft.net>
 <20120119195349.GN2262734@jupiter.n2.diac24.net>
 <20120119.152752.318442465605898328.davem@davemloft.net>
 <m1lip32xoi.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, equinox@diac24.net,
	hans.schillstrom@ericsson.com, netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:53635 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752850Ab2ASVlA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jan 2012 16:41:00 -0500
Content-Disposition: inline
In-Reply-To: <m1lip32xoi.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Eric W. Biederman | 2012-01-19 13:24:13 [-0800]:

>This thread is a fascinating disconnect from reality all of the way
>around.
>
>- inet_twsk_purge already implements throwing out of timewait sockets
>  when a network namespaces is being cleaned up.  So the RFC is nonsense.

This is how it is implemented, not how it should be. TIME_WAIT is not the
problem, it is there to keep the stack from sending wrong RST messages. Maybe
the 2*MSL could be fixed by a more accurate 2*RTT.

>- Keeping the timewait sockets at that point we purge them in the code
>  can achieve nothing.  We don't have any userspace processes or network
>  devices associated with the timewait sockets at the point we get rid
>  of them.  The network namespace exists so long as a userspace process
>  can find it.  The network namespace exit is asynchronous in it's own
>  workqueue so userspace definitely is not blocked.

Another possible solution could be a netns global TIME_WAIT list. But this
is a little bit expensive and out of question - but this _is_ a convenient
solution.

The "5 second reboot" is no argument - it show a discrepance between TCP
requirements and the actual situation.

Hagen
