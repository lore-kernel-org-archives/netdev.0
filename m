From: David Miller <davem@davemloft.net>
Subject: Re: [Xen-devel] [PATCHv1 net-next] xen-netback: remove
 unconditional pull_skb_tail in guest Tx path
Date: Wed, 05 Nov 2014 12:15:11 -0500 (EST)
Message-ID: <20141105.121511.887564988610007845.davem@davemloft.net>
References: <5457C807.5080509@linaro.org>
	<20141104.161704.1690311989900127361.davem@davemloft.net>
	<1415181080.11486.63.camel@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: zoltan.kiss@linaro.org, david.vrabel@citrix.com,
	netdev@vger.kernel.org, malcolm.crossley@citrix.com,
	wei.liu2@citrix.com, xen-devel@lists.xenproject.org
To: Ian.Campbell@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44163 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751562AbaKERPQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2014 12:15:16 -0500
In-Reply-To: <1415181080.11486.63.camel@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ian Campbell <Ian.Campbell@citrix.com>
Date: Wed, 5 Nov 2014 09:51:20 +0000

> Is this also true for things which hit the iptables paths? I suppose
> they must necessarily have already been through the protocol demux stage
> before iptables would even be able to interpret them as e.g. an IP
> packet.

Netfilter often takes a different approach, by using
skb_header_pointer() which returns a direct pointer if the linear area
contains the requested range already, or alternatively copies from the
frags into a user supplied on-stack header buffer if not.
