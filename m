From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] net: add ability to clear stats via ethtool - e1000/pcnet32
Date: Sun, 1 Jun 2008 23:29:08 +0100
Message-ID: <20080601222906.GH30769@solarflare.com>
References: <482FBA09.80201@sngx.net> <483E0AAE.2020107@sngx.net> <20080528221118.63da4092.akpm@linux-foundation.org> <483EA2D1.8050603@sngx.net> <20080529154525.3916c7b5@core> <20080530151250.b44a119a.billfink@mindspring.com> <20080531131143.516ca56e@core> <20080531195702.0b879dd1.billfink@mindspring.com> <20080601014620.GG30769@solarflare.com> <20080601164614.012fe1f6.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>,
	James Cammarata <jimi@sngx.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: Bill Fink <billfink@mindspring.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 82-69-137-158.dsl.in-addr.zen.co.uk ([82.69.137.158]:39566 "EHLO
	uklogin.uk.level5networks.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751956AbYFAW3d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jun 2008 18:29:33 -0400
Content-Disposition: inline
In-Reply-To: <20080601164614.012fe1f6.billfink@mindspring.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bill Fink wrote:
> On Sun, 1 Jun 2008, Ben Hutchings wrote:
> 
> > Bill Fink wrote:
> > <snip>
> > > Yes, every individual Linux network administrator can re-create the
> > > wheel by devising their own scripts, but it makes much more sense
> > > to me to implement a simple general kernel mechanism once that could
> > > be used generically, than to have hundreds (or thousands) of Linux
> > > network administrators each having to do it themselves (perhaps
> > > multiple times if they have a variety of types of systems and types
> > > of NICs).
> > 
> > The ethtool interface is pretty generic, even if the names aren't.
> > Here's some Python code I just knocked up which demonstrates how
> > to get a set of named stats.  It shouldn't be terribly hard to
> > extend this to saving and subtracting stat sets.
> 
> I'm not sure what that proves.  Your python code just basically gives
> the same info as running the "ethtool -S" command.

Yes, but in a form you can more easily manipulate.

> But the question
> is how does one devise a generic script or tool that doesn't require
> any special knowledge of the specific NIC being used.  For example,
> here's the "ethtool -S" info for my myri10ge NIC:
> 
> [root@chance8 ~]# ethtool -S eth2
> NIC statistics:
[...]
>      WC: 1
>      irq: 8413
>      MSI: 1
>      read_dma_bw_MBs: 1398
>      write_dma_bw_MBs: 1613
>      read_write_dma_bw_MBs: 2711
>      serial_number: 287046
[...]
>      tx_linearized: 0
>      link_changes: 8
>      link_up: 1
[...]
> 
> How does one know which of these reported values are counter stats
> that one wishes to zero/snapshot, and which are not?

Ah, I see, I didn't realise some drivers were abusing ethtool stats in
this way.  But for the most part the differences will show up as zeroes.

If there's really a need for ethtool stats that aren't counters,
maybe the ethtool API should include flags to indicate which they are.

> Another issue that occurred to me is if multiple people are working
> on troubleshooting a network problem, how do we insure that they all
> get a consistent view of the stats?  If this is done via a kernel
> mechanism then there isn't an issue.  But if it's done via user space,
> then you have to make sure that everyone zeros/snapshots the stats
> at the same time.
> 
> Ideally, one should be able to do something like "ethtool -z ethX"
> to zero/snapshot the driver stats, and then "ethtool -S ethX" to get
> the stats since the last snapshot.  You should be able to use the
> same tool ("ethtool") to do all of this, and not some other special
> tool or specially devised homegrown script.  Why make users lives
> any more difficult than need be?

No-one's stopping you from adding these options to ethtool.  You could
have it save statistic sets in, say, /var/run/ethtool.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
