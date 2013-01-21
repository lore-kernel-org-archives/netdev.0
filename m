From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [RFC:] struct net_device_ops: Add function pointer to fill device
 specific ndisc information
Date: Mon, 21 Jan 2013 21:32:53 +0900
Message-ID: <50FD3575.1060303@linux-ipv6.org>
References: <50FC2EE4.3080705@gmail.com> <20130120212233.GA6776@ppwaskie-mobl2.amr.corp.intel.com> <50FCDD89.3020403@gmail.com> <20130121092806.3c741bd2@stein>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: stephan.gatzka@gmail.com,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	linux1394-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	davem@davemloft.net, YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Stefan Richter <stefanr@s5r6.in-berlin.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:50059 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752680Ab3AUMc5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2013 07:32:57 -0500
In-Reply-To: <20130121092806.3c741bd2@stein>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stefan Richter wrote:

>   b) RFC 2734 MCAP (Multicast Channel Allocation Protocol):  currently not
>      implemented; not sure if needed (I see a few big downsides to using
>      per-multicast-group channels); not sure if networking core support
>      would be needed for this

It is definitely needed because we need to listen on multicast group
for NDP, which might have already had its own channel.

MCAP sends "multicast group address", which is whole IP address.
In IP stack we only manages listening groups by special
"link-layer address" mapped by device specific transform function.
See net/ipv6/ndiscc:ndisc_mc_map() for IPv6.

I am proposing to extend MAC address to 16 bytes long so that we can
"map" whole IPv6 address into the "MAC".

On tx on fwnet, it can determine if the destination is multicast or not
by either by
- Checking protocol, and looking into protocol dependent multicast
  range
or
- Checking "EUI-64" group bit (here, we assume all node do not set it
  in its unique Id, and we map IPv6 multicast and IPv4 multicast in
  special way; e.g.
     ff00::/8  (which has "multicast bit" set)
     0100::/96 (which is also "multicast bit" set)

--yoshfuji
