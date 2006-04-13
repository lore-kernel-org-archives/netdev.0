From: Pete Zaitcev <zaitcev@redhat.com>
Subject: Re: [patch 1/3] softmac: return -EAGAIN from getscan while scanning
Date: Thu, 13 Apr 2006 15:28:53 -0700
Message-ID: <20060413152853.149186fb.zaitcev@redhat.com>
References: <20060411085805.949313000@sipsolutions.net>
	<20060411085841.252064000@sipsolutions.net>
	<20060413020010.2ab16d7b.zaitcev@redhat.com>
	<1144930375.2372.10.camel@localhost.localdomain>
	<1144930766.4187.80.camel@localhost>
	<20060413160051.GE15499@instant802.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: johannes@sipsolutions.net, dcbw@redhat.com, netdev@vger.kernel.org,
	linville@tuxdriver.com, softmac-dev@sipsolutions.net,
	zaitcev@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:51940 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S965003AbWDMW3R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Apr 2006 18:29:17 -0400
To: "Jouni Malinen" <jkm@devicescape.com>
In-Reply-To: <20060413160051.GE15499@instant802.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 13 Apr 2006 09:00:51 -0700, "Jouni Malinen" <jkm@devicescape.com> wrote:

> That could be blocking an ioctl call for couple of seconds
> and would be quite horrible for single threaded programs.

I would say that waiting for couple of seconds in the kernel would
be quite wonderful for single threaded programs, when you consider
the alternative. I can guess now what your concern is, even though
you failed to articulate it: a single-threaded GUI application,
which cannot respond to events when blocked in getting scan results.
If that's the case, we should be looking at having both blocking
and non-blocking calls to fetch scan results.

> [...] but what if some other program were
> to request a new scan between the completion event and the attempt to
> read the previous scan results..

I do not see how this is relevant.

-- Pete
