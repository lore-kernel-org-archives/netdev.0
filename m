From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [patch 1/3] softmac: return -EAGAIN from getscan while scanning
Date: Thu, 13 Apr 2006 16:03:36 -0700
Message-ID: <20060413160336.7a430c04@localhost.localdomain>
References: <20060413160051.GE15499@instant802.com>
	<20060413152853.149186fb.zaitcev@redhat.com>
	<20060413224522.GK15499@instant802.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Pete Zaitcev <zaitcev@redhat.com>, johannes@sipsolutions.net,
	dcbw@redhat.com, netdev@vger.kernel.org, linville@tuxdriver.com,
	softmac-dev@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:44956 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751185AbWDMXFV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Apr 2006 19:05:21 -0400
To: "Jouni Malinen" <jkm@devicescape.com>
In-Reply-To: <20060413224522.GK15499@instant802.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 13 Apr 2006 15:45:22 -0700
"Jouni Malinen" <jkm@devicescape.com> wrote:

> On Thu, Apr 13, 2006 at 03:28:53PM -0700, Pete Zaitcev wrote:
> > On Thu, 13 Apr 2006 09:00:51 -0700, "Jouni Malinen" <jkm@devicescape.com> wrote:
> > 
> > > That could be blocking an ioctl call for couple of seconds
> > > and would be quite horrible for single threaded programs.
> > 
> > I would say that waiting for couple of seconds in the kernel would
> > be quite wonderful for single threaded programs, when you consider
> > the alternative. I can guess now what your concern is, even though
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
> 
> > > [...] but what if some other program were
> > > to request a new scan between the completion event and the attempt to
> > > read the previous scan results..
> > 
> > I do not see how this is relevant.
> 
> That would make the application wait even if it properly waited for the
> scan complete event before reading the scan result. If the get-results
> call is blocking, the single-threaded application simply don't have any
> easy way of getting the results while being able to do something else
> while waiting for the scan to complete. Furthermore, blocking ioctl
> handlers is not really something I would like to see in the kernel..
> Aren't there some locks/semaphores/etc. kept for some cases?
> 

Sounds like you want a message interface like netlink, not ioctl's.
