From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH net-2.6.25 uncompilable] [TCP]: Avoid breaking
 GSOed skbs when SACKed one-by-one
Date: Wed, 12 Dec 2007 07:11:36 -0800 (PST)
Message-ID: <20071212.071136.26499607.davem@davemloft.net>
References: <Pine.LNX.4.64.0712081523470.17809@kivilampi-30.cs.helsinki.fi>
	<20071211.043239.224938181.davem@davemloft.net>
	<aa7d2c6d0712111614k2832f51axa8bc9736ac7ec796@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ilpo.jarvinen@helsinki.fi, netdev@vger.kernel.org,
	quetchen@caltech.edu
To: lachlan.andrew@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59995
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751037AbXLLPLk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2007 10:11:40 -0500
In-Reply-To: <aa7d2c6d0712111614k2832f51axa8bc9736ac7ec796@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Lachlan Andrew" <lachlan.andrew@gmail.com>
Date: Tue, 11 Dec 2007 16:14:36 -0800

> This thread started because TCP processing interferes with RTT
> estimation.  This problem would be eliminated if time-stamping were
> done as soon as the packet comes off the NIC.

We don't do that because such timestamping is too expensive.

It used to be the case that we did this, but we stopped doing
that a long time ago.

On x86 for example, timestamping can involve touching a slow
I/O device to read the timestamp.  We do not want to do that
for every packet.

Also, we timestamp differently for TCP, the global high
resolution timestamp is overkill for this purpose.

Really, this is a silly idea and would only be a bandaid
for the problem at hand, that TCP input processing is
too expensive in certain circumstances.

