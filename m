From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: RE: packetloss, on e1000e worse than r8169?
Date: Wed, 18 Jun 2008 09:50:07 -0700
Message-ID: <36D9DB17C6DE9E40B059440DB8D95F52056F2823@orsmsx418.amr.corp.intel.com>
References: <20080616193501.M64730@visp.net.lb> <20080616220841.M50112@visp.net.lb> <36D9DB17C6DE9E40B059440DB8D95F52056AC4C2@orsmsx418.amr.corp.intel.com> <200806180004.49272.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Eric Dumazet" <dada1@cosmosbay.com>, <netdev@vger.kernel.org>
To: "Denys Fedoryshchenko" <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:29303 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751971AbYFRQuk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jun 2008 12:50:40 -0400
Content-class: urn:content-classes:message
In-Reply-To: <200806180004.49272.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Denys Fedoryshchenko wrote:
> After trying everything, it looks like that problem in PBS size, and
> as result PBA (rx fifo) size. 

agreed
 
> On ICH8 it is small, only 16K PBS (0x10), and RX/TX set each 8k, even
> i can set 0xd/0x3 it doesn't help (i didn't measure if it make less

just to make sure, you set PBA=0xd, correct?

> packetloss). As i understand, i need to set only RX, TX calculated
> automatically.  Both motherboards i tried had ICH8.

your understanding is correct, the lower 8 bits represent rx fifo size,
and the tx fifo size is computed based on the result of (PBS - (lower 8
bits of)PBA)

Please note this is mostly documented in the software developers manuals
posted both at intel.com and e1000.sourceforge.net.  ICH8 documentation
is mostly covered in the chipset documentation.
 
> All other servers which i mention, and which have enough big load
> have: 1)Sun - PBA 48K (82546EB)
> 2)DP35DP - PBA 16K (ICH9)
> 
> Also ICH8 missing some features, that ICH9 supports, such as
> FLAG_HAS_ERT, but it looks ERT useful only for Jumbo frames. 
> And sure ICH8 doesn't support Jumbo frames, maybe because of limited
> PBS. 
> 
> Is PBS size hardware limitation of ICH8?
yes, working size of the FIFO is 16kB total (PBS)

> Is it possible i am right in my conclusions?
yes, client parts will not buffer as much data (generally) due to
smaller FIFO as the server parts, which typically have 64kB total FIFO.

> Probably such details in network adapters will be useful for Vyatta
> guys, to choose proper network adapter for their systems :-) 

agreed, the rule here would be don't use client parts for server class
workloads, unfortunately we don't control what machines certain server
vendors put client parts like 82573, ICH8/ICH9 in, so sometimes you have
a "low end" server with a client gigabit ethernet part.
