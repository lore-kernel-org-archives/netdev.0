From: Thomas Graf <tgraf@suug.ch>
Subject: Re: Regression in current git - Network Manager fails (bisected)
Date: Tue, 23 Oct 2007 14:11:23 +0200
Message-ID: <20071023121123.GA8125@postel.suug.ch>
References: <20071022005857.GA6317@nineveh.local> <471C6BEC.4010604@sw.ru> <1193068645.30205.22.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Denis V. Lunev" <den@sw.ru>, netdev@vger.kernel.org,
	"Denis V. Lunev" <den@openvz.org>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:51356 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751846AbXJWMLF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Oct 2007 08:11:05 -0400
Content-Disposition: inline
In-Reply-To: <1193068645.30205.22.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Dan Williams <dcbw@redhat.com> 2007-10-22 11:57
> On Mon, 2007-10-22 at 13:22 +0400, Denis V. Lunev wrote:
> > We have spent some time with the problem with Alexey and there are no 
> > guesses for now.
> > 
> > Is it possible to name exact version of Network Manager and all 
> > libraries related + provide us an output of strace with full buffers 
> > send/received from netlink. Something like
> >      strace -v -x -s 32768 <nm>
> 
> NM uses netlink in two places; libnl (from Thomas Graf) and some custom
> code for listening for interface up/down events and wireless events.
> 
> It looks like that code comes from libnl's lib/handlers.c where it
> thinks the received message is invalid.
> 
> I'm pretty sure the code that checks carrier status of the device isn't
> libnl code; so maybe the error message (which should get fixed of
> course) isn't in the same path as the link detection.
> 
> The link detection comes from src/nm-netlink-monitor.c, so maybe we
> should look at debugging there.

The patch introduced a change in semantics because it removed the
special ACK handling after a dump was started.

I will look into this.
