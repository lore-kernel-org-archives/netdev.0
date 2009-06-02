From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4] net: skb_orphan on dev_hard_start_xmit
Date: Tue, 02 Jun 2009 00:25:53 -0700 (PDT)
Message-ID: <20090602.002553.143476036.davem@davemloft.net>
References: <200905292344.56814.rusty@rustcorp.com.au>
	<1243885642.22917.35.camel@pohly-MOBL>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rusty@rustcorp.com.au, netdev@vger.kernel.org,
	virtualization@lists.linux-foundation.org, divy@chelsio.com,
	rolandd@cisco.com, xemul@openvz.org, dcbw@redhat.com,
	libertas-dev@lists.infradead.org
To: patrick.ohly@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49691
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754706AbZFBHZw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2009 03:25:52 -0400
In-Reply-To: <1243885642.22917.35.camel@pohly-MOBL>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick Ohly <patrick.ohly@intel.com>
Date: Mon, 01 Jun 2009 21:47:22 +0200

> On Fri, 2009-05-29 at 23:44 +0930, Rusty Russell wrote:
>> This patch adds skb_orphan to the start of dev_hard_start_xmit(): it
>> can be premature in the NETDEV_TX_BUSY case, but that's uncommon.
> 
> Would it be possible to make the new skb_orphan() at the start of
> dev_hard_start_xmit() conditionally so that it is not executed for
> packets that are to be time stamped?
> 
> As discussed before
> (http://article.gmane.org/gmane.linux.network/121378/), the skb->sk
> socket pointer is required for sending back the send time stamp from
> inside the device driver. Calling skb_orphan() unconditionally as in
> this patch would break the hardware time stamping of outgoing packets.

Indeed, we need to check that case, at a minimum.

And there are other potentially other problems.  For example, I
wonder how this interacts with the new TX MMAP af_packet support
in net-next-2.6 :-/

