From: "Jouni Malinen" <jkm@devicescape.com>
Subject: Re: [patch 1/3] softmac: return -EAGAIN from getscan while scanning
Date: Thu, 13 Apr 2006 15:45:22 -0700
Message-ID: <20060413224522.GK15499@instant802.com>
References: <20060413160051.GE15499@instant802.com> <20060413152853.149186fb.zaitcev@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: johannes@sipsolutions.net, dcbw@redhat.com, netdev@vger.kernel.org,
	linville@tuxdriver.com, softmac-dev@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-80.dex002.intermedia.net ([64.78.20.165]:7572 "EHLO
	DHOST002-80.dex002.intermedia.net") by vger.kernel.org with ESMTP
	id S1751151AbWDMWpc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Apr 2006 18:45:32 -0400
To: Pete Zaitcev <zaitcev@redhat.com>
Content-Disposition: inline
In-Reply-To: <20060413152853.149186fb.zaitcev@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 13, 2006 at 03:28:53PM -0700, Pete Zaitcev wrote:
> On Thu, 13 Apr 2006 09:00:51 -0700, "Jouni Malinen" <jkm@devicescape.com> wrote:
> 
> > That could be blocking an ioctl call for couple of seconds
> > and would be quite horrible for single threaded programs.
> 
> I would say that waiting for couple of seconds in the kernel would
> be quite wonderful for single threaded programs, when you consider
> the alternative. I can guess now what your concern is, even though
> you failed to articulate it: a single-threaded GUI application,
> which cannot respond to events when blocked in getting scan results.
> If that's the case, we should be looking at having both blocking
> and non-blocking calls to fetch scan results.

No, my main concern was single-threaded design in wpa_suppliant.. If the
ioctl call is blocking, I would need to create a new (well, the first
additional) thread just for this use. Without that, the blocking call
would also block all control interface commands (interaction with
external programs) and controlling of other interfaces (if more than one
is used).

> > [...] but what if some other program were
> > to request a new scan between the completion event and the attempt to
> > read the previous scan results..
> 
> I do not see how this is relevant.

That would make the application wait even if it properly waited for the
scan complete event before reading the scan result. If the get-results
call is blocking, the single-threaded application simply don't have any
easy way of getting the results while being able to do something else
while waiting for the scan to complete. Furthermore, blocking ioctl
handlers is not really something I would like to see in the kernel..
Aren't there some locks/semaphores/etc. kept for some cases?

-- 
Jouni Malinen                                            PGP id EFC895FA
