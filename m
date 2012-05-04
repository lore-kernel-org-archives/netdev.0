From: Jiri Bohac <jbohac@suse.cz>
Subject: Re: bonding: don't increase rx_dropped after processing LACPDUs
Date: Fri, 4 May 2012 14:15:45 +0200
Message-ID: <20120504121545.GA32665@midget.suse.cz>
References: <20120502202309.GA25355@midget.suse.cz>
 <1335991009.22133.639.camel@edumazet-glaptop>
 <20120502205118.GB25355@midget.suse.cz>
 <1765.1336000239@death.nxdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Bohac <jbohac@suse.cz>, Eric Dumazet <eric.dumazet@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:58520 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755472Ab2EDMPr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 May 2012 08:15:47 -0400
Content-Disposition: inline
In-Reply-To: <1765.1336000239@death.nxdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 02, 2012 at 04:10:39PM -0700, Jay Vosburgh wrote:
> 	Won't this make it impossible to bind a PF_PACKET socket to
> sll_protocol == ETH_P_SLOW and see the LACPDUs, but only when bonding is
> running 802.3ad? 

yes it will...

> This because the ptype_all check in
> __netif_receive_skb happens before the rx_handler, but the ptype_base
> check (bound packet socket, for example) happens after.  Currently,
> libpcap looks to bind to ETH_P_ALL, so it won't be affected.

Does it make any sense for the packet socket not to bind to
ETH_P_ALL? With all the rx_handlers interfering with the packet
(e.g. modifying skb->dev, modifying the MAC address), binding to
ETH_P_SLOW will never reliably get you the the original frame
with reliable information about the incoming device. 

> If so, is that something we care about?

I think not.
 

-- 
Jiri Bohac <jbohac@suse.cz>
SUSE Labs, SUSE CZ
