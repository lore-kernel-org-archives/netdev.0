From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [RFC:] struct net_device_ops: Add function pointer to fill device
 specific ndisc information
Date: Mon, 21 Jan 2013 23:15:21 +0900
Message-ID: <50FD4D79.1000308@linux-ipv6.org>
References: <50FC2EE4.3080705@gmail.com> <20130120212233.GA6776@ppwaskie-mobl2.amr.corp.intel.com> <50FCDD89.3020403@gmail.com> <20130121092806.3c741bd2@stein> <50FD3575.1060303@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	Stefan Richter <stefanr@s5r6.in-berlin.de>,
	stephan.gatzka@gmail.com,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	linux1394-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	davem@davemloft.net
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:50169 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752735Ab3AUOPX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2013 09:15:23 -0500
In-Reply-To: <50FD3575.1060303@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

YOSHIFUJI Hideaki wrote:
> Stefan Richter wrote:
> 
>>   b) RFC 2734 MCAP (Multicast Channel Allocation Protocol):  currently not
>>      implemented; not sure if needed (I see a few big downsides to using
>>      per-multicast-group channels); not sure if networking core support
>>      would be needed for this
> 
> It is definitely needed because we need to listen on multicast group
> for NDP, which might have already had its own channel.

Sorry, this was unclear and incorrect.  RFC3146 Section 9
(IPv6 Multicast) says that packets for all-nodes/all-routers/
solicited-node multicast addresses must be sent via broadcast
channel.  So, NDP should work without MCAP.

But, even so, I do not want to have broken implementation without
MCAP, or at least, we need prepare to support full multicast.
I do NOT want to have patchy implementation just for NDISC.

With extended MAC, networking core (including IPv4/IPv6) does not
need to be changed very much for supporting MCAP; no new hooks,
no new callbacks.

--yoshfuji
