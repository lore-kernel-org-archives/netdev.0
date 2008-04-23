From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [PATCH v2] Re: WAN: new PPP code for generic HDLC
Date: Wed, 23 Apr 2008 19:02:22 +0200
Message-ID: <m34p9smrmp.fsf@maximus.localdomain>
References: <m33apdyajf.fsf@maximus.localdomain>
	<480E5CB3.2080003@microgate.com> <480E4FA1.5020508@garzik.org>
	<20080422.150559.115368150.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, paulkf@microgate.com, jchapman@katalix.com,
	alan@lxorguk.ukuu.org.uk, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from OSB1387.piap.pl ([195.187.100.11]:33332 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751032AbYDWRCZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Apr 2008 13:02:25 -0400
In-Reply-To: <20080422.150559.115368150.davem@davemloft.net> (David Miller's message of "Tue\, 22 Apr 2008 15\:05\:59 -0700 \(PDT\)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

> The fact that non-HDLC users of syncppp got left broken

The fact is it isn't broken WRT dev->priv at least (I don't know about
random unrelated breakage).

The drivers:
a) alloc a netdev
b) set dev->priv to some private kmalloced area

It was like that for years, and it worked. The commit in question
changed netdev_priv() and the drivers don't use this function.

netdev_priv() was introduced at some point in time to allow
alloc_netdev() to optionally allocate additional memory for internal
use by the driver. It had nothing to do with dev->priv except "priv"
name. The drivers don't use it passing size 0.

This is probably suboptimal (two+ allocations instead of one), if the
drivers had maintainers with access to hardware I guess it would be
optimized, but it has nothing to do with the regression.

The regression is present in HDLC PPP only, becase HDLC PPP actually
used netdev_priv() (unlike non-HDLC PPP cases) as a means of addressing
the area following net_device struct and not for retrieving dev->priv,
and then the semantics suddenly changed.

> I would have been more than happy if syncppp was retained and fixed
> properly, instead of being abandoned and duplicated in one fell swoop.

I would be happy as well. The problem is that nobody shown any idea
how to do it.

I have offered: I will port any existing sync serial driver to generic
HDLC if I'm sent a free hardware sample. That includes old ISA cards
(I still have an old 2*PII-333 ISA test machine), and porting PC300
T1/E1 code to pc300too.

If some driver/hw has no users I think there is no point in keeping it
on life support here. The same goes for syncppp - if/when the number
of drivers using it drops to zero, we can let it go.
-- 
Krzysztof Halasa
