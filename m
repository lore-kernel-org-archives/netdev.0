From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] IPv4 raw_hdrincl_nomangle sysctl
Date: Wed, 17 Dec 2008 12:48:41 -0800 (PST)
Message-ID: <20081217.124841.169000877.davem@davemloft.net>
References: <494964CA.5050109@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: katterjohn@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35512
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751463AbYLQUsj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2008 15:48:39 -0500
In-Reply-To: <494964CA.5050109@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kris Katterjohn <katterjohn@gmail.com>
Date: Wed, 17 Dec 2008 14:44:58 -0600

> I've attached a patch to add a net.ipv4.raw_hdrincl_nomangle sysctl (defaults
> to 0) to control whether or not Linux changes the header passed using
> IP_HDRINCL (checksum, IPID, etc).  This way it's not required to build a
> special kernel simply to have control over what you send.  This was needed,
> for example, in this discussion[1] on Nmap's packet handling.

If you want full control, use AF_PACKET to send your frames.

Yes, this means you'll need to choose the outgoing device and compose
the link level header, but that's the price for control.

Using IPV4 RAW sockets implies you want some help from that
part of the stack, if you don't then simply use direct pure
packet sends via AF_PACKET.
