From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: skbuff truesize incorrect.
Date: Fri, 23 May 2014 08:41:35 -0700
Message-ID: <1400859695.5367.203.camel@edumazet-glaptop2.roam.corp.google.com>
References: <537E4AFD.20304@mentor.com>
	 <1400792295.5367.174.camel@edumazet-glaptop2.roam.corp.google.com>
	 <063D6719AE5E284EB5DD2968C1650D6D1724C490@AcuExch.aculab.com>
	 <87r43k4yhe.fsf@nemi.mork.no>
	 <063D6719AE5E284EB5DD2968C1650D6D1724C7A1@AcuExch.aculab.com>
	 <537F2D53.5020408@mentor.com>
	 <1400852843.5367.191.camel@edumazet-glaptop2.roam.corp.google.com>
	 <063D6719AE5E284EB5DD2968C1650D6D1724CACF@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jim Baxter <jim_baxter@mentor.com>,
	=?ISO-8859-1?Q?=27Bj=F8rn?= Mork' <bjorn@mork.no>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"kamal@canonical.com" <kamal@canonical.com>,
	"edumazet@google.com" <edumazet@google.com>,
	"mszeredi@suse.cz" <mszeredi@suse.cz>,
	"fw@strlen.de" <fw@strlen.de>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:41909 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751628AbaEWPlh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 May 2014 11:41:37 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1724CACF@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-05-23 at 15:30 +0000, David Laight wrote:
> From: Eric Dumazet
> ...
> > TCP stack uses fast clones, and current stack gives them a truesize of
> > 2048 + sizeof(sk_buff), while it really should be 2048 +
> > 2*sizeof(sk_buff)
> > 
> > Luckily, GSO/TSO tends to reduce the error, as skbs overhead is lower.
> 
> Doesn't that affect the tx side - where the truesize doesn't matter as much?

Its not a matter of tx or rx, but percentage of error.

If truesize accounting is wrong by 10%, its not a big deal, because we
normally limit tcp_mem[] to about 16% of available physical memory.

Using 16% of physical memory instead of 16% should not really matter.

Now, if the truesize is wrong by 1600%, then its pretty clear we can
consume all the meory.
