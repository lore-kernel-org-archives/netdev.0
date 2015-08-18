From: Phil Sutter <phil@nwl.cc>
Subject: Re: [PATCH 20/21] net: warn if drivers set tx_queue_len = 0
Date: Tue, 18 Aug 2015 20:14:40 +0200
Message-ID: <20150818181440.GB20744@orbit.nwl.cc>
References: <1439886649-24166-13-git-send-email-phil@nwl.cc>
 <1439886649-24166-14-git-send-email-phil@nwl.cc>
 <1439886649-24166-15-git-send-email-phil@nwl.cc>
 <1439886649-24166-16-git-send-email-phil@nwl.cc>
 <1439886649-24166-17-git-send-email-phil@nwl.cc>
 <1439886649-24166-18-git-send-email-phil@nwl.cc>
 <1439886649-24166-19-git-send-email-phil@nwl.cc>
 <1439886649-24166-20-git-send-email-phil@nwl.cc>
 <1439886649-24166-21-git-send-email-phil@nwl.cc>
 <1439909248.6443.19.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, brouer@redhat.com, davem@davemloft.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:48708 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751318AbbHRSOm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Aug 2015 14:14:42 -0400
Content-Disposition: inline
In-Reply-To: <1439909248.6443.19.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 18, 2015 at 07:47:28AM -0700, Eric Dumazet wrote:
> On Tue, 2015-08-18 at 10:30 +0200, Phil Sutter wrote:
> > Due to the introduction of IFF_NO_QUEUE, there is a better way for
> > drivers to indicate that no qdisc should be attached by default. Though,
> > the old convention can't be dropped since ignoring that setting would
> > break drivers still using it. Instead, add a warning so out-of-tree
> > driver maintainers get a chance to adjust their code before we finally
> > get rid of any special handling of tx_queue_len == 0.
> 
> How an admin can remove qdisc on a regular ethernet device with this
> schem ?
> 
> I was doing :
> 
> tc qdisc replace dev eth0 root pfifo
> ifconfig eth0 txqueuelen 0
> tc qdisc del dev eth0 root
> 
> 
> I see nothing in your patches to avoid the DEPRECATED warning.

Well, the warning is printed only upon interface registration, so
affects only drivers which set tx_queue_len = 0 by default. If you do
the above, you won't hit that check.

But you've got a point here: If we drop the special handling of
tx_queue_len == 0, there won't be any chance to change a non-virtual
interface's qdisc to noqueue anymore. This is definitely something to
reconsider before going any further.

Thanks, Phil
