From: Phil Sutter <phil@nwl.cc>
Subject: Re: [[net-next] lo uses DEPRECATED zero tx_queue_len - convert
 driver to use IFF_NO_QUEUE instead
Date: Wed, 26 Aug 2015 13:03:52 +0200
Message-ID: <20150826110352.GA28613@orbit.nwl.cc>
References: <CAMuHMdX6O3_wtWagwAKgVd=aifXjVd5rw8VczF18VS9+Mm30oQ@mail.gmail.com>
 <20150826093426.GA20760@orbit.nwl.cc>
 <CAMuHMdVFNnfDFO0Kqz=N3rFW7_3O8ha3Da80bMaEeVozducw9w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:46496 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756038AbbHZLDy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Aug 2015 07:03:54 -0400
Content-Disposition: inline
In-Reply-To: <CAMuHMdVFNnfDFO0Kqz=N3rFW7_3O8ha3Da80bMaEeVozducw9w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Geert,

On Wed, Aug 26, 2015 at 12:16:47PM +0200, Geert Uytterhoeven wrote:
> On Wed, Aug 26, 2015 at 11:34 AM, Phil Sutter <phil@nwl.cc> wrote:
> > On Tue, Aug 25, 2015 at 01:16:41PM +0200, Geert Uytterhoeven wrote:
> >> I don't know if this was reported before (I'm not subscribed to netdev), but
> >> Google couldn't find it:
> >>
> >> lo uses DEPRECATED zero tx_queue_len - convert driver to use
> >> IFF_NO_QUEUE instead
> >
> > This is fixed by commit e65db2b ("net: loopback: convert to using
> > IFF_NO_QUEUE"), part of a bigger series converting drivers (see here:
> > http://lists.openwall.net/netdev/2015/08/18/52).
> 
> Strange, that commit is included in my tree, which is based on
> https://git.kernel.org/cgit/linux/kernel/git/geert/renesas-drivers.git/
> and includes net-next?

I'm sorry, the above statement was too quickly put. Florian Westphal
confirmed the problem you are seeing privately, and I can follow from
looking at the code. Obviously I failed to notice that by using
alloc_netdev instead of alloc_etherdev, there is a way for drivers to
circumvent ether_setup completely which leaves tx_queue_len
uninitialized (i.e., 0) and therefore triggers the warning.

I'm yet unsure how to properly fix this issue, but moving the check to a
more appropriate place is certainly advisable.

Thanks for pointing this out,

Phil
