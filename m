From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH v4 net-next] r8169: Add values missing in @get_stats64
 from HW counters
Date: Wed, 26 Aug 2015 00:54:06 +0200
Message-ID: <20150825225406.GA24297@electric-eye.fr.zoreil.com>
References: <1439888664-28620-1-git-send-email-vinschen@redhat.com>
 <1440413559-9354-1-git-send-email-vinschen@redhat.com>
 <20150825.141540.472110106537790402.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vinschen@redhat.com, netdev@vger.kernel.org, hayeswang@realtek.com,
	ivecera@redhat.com, nic_swsd@realtek.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:34421 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752105AbbHYWyn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2015 18:54:43 -0400
Content-Disposition: inline
In-Reply-To: <20150825.141540.472110106537790402.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> :
[...]
> Your counter offsets should be read at probe time, not open time.

It can be done but the "CmdRxEnb / rx traffic must be enabled" constraint
will make it a major pita. 

Reading counter offsets at the end of open() naturally solves this
constraint (retentive error unwinding in opne() stops being completely
trivial though :o/ ).

> Bringing the interface is brought down/up should not reset the
> counters.

Afaiks rtl8169_tc_offsets.inited in rtl8169_init_counter_offsets
takes care of it: it's set during the first open() after probe().

Looking at it again, the patch directly stores 16 and 32 bit values
in rtnl_link_stats64. Nobody should care about exact exceedingly high
error count but rx_multicast ought to be accumulated.

-- 
Ueimor
