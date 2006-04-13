From: Pete Zaitcev <zaitcev@redhat.com>
Subject: Re: [patch 1/3] softmac: return -EAGAIN from getscan while scanning
Date: Thu, 13 Apr 2006 16:35:25 -0700
Message-ID: <20060413163525.6d866fee.zaitcev@redhat.com>
References: <20060413160051.GE15499@instant802.com>
	<20060413152853.149186fb.zaitcev@redhat.com>
	<20060413224522.GK15499@instant802.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: johannes@sipsolutions.net, dcbw@redhat.com, netdev@vger.kernel.org,
	linville@tuxdriver.com, softmac-dev@sipsolutions.net,
	zaitcev@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:19368 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S965049AbWDMXhZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Apr 2006 19:37:25 -0400
To: "Jouni Malinen" <jkm@devicescape.com>
In-Reply-To: <20060413224522.GK15499@instant802.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 13 Apr 2006 15:45:22 -0700, "Jouni Malinen" <jkm@devicescape.com> wrote:

> > [...] I can guess now what your concern is, even though
> > you failed to articulate it: a single-threaded GUI application,
> > which cannot respond to events when blocked in getting scan results.
> > If that's the case, we should be looking at having both blocking
> > and non-blocking calls to fetch scan results.
> 
> No, my main concern was single-threaded design in wpa_suppliant.. If the
> ioctl call is blocking, I would need to create a new (well, the first
> additional) thread just for this use. Without that, the blocking call
> would also block all control interface commands (interaction with
> external programs) and controlling of other interfaces (if more than one
> is used).

I see... Thanks for explainig it.

> [...] Furthermore, blocking ioctl
> handlers is not really something I would like to see in the kernel..
> Aren't there some locks/semaphores/etc. kept for some cases?

I think you are taking this concept too far. Consider things like
an ioctl to seek a magnetic tape N files forward, or an ioctl to
flush characters to a terminal. They seem to work fine in blocking
mode. And no, we do not have a generic API to expose semaphores
(I suppose you did not mean SYSV IPC above :-).

-- Pete
