From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][IPSEC][6/7] inter address family ipsec tunnel
Date: Thu, 30 Nov 2006 17:05:03 -0800 (PST)
Message-ID: <20061130.170503.35356518.davem@davemloft.net>
References: <20061124143901.0db589b8.kazunori@miyazawa.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: miika@iki.fi, Diego.Beltrami@hiit.fi, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:26535
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1031666AbWLABFB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Nov 2006 20:05:01 -0500
To: kazunori@miyazawa.org
In-Reply-To: <20061124143901.0db589b8.kazunori@miyazawa.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kazunori MIYAZAWA <kazunori@miyazawa.org>
Date: Fri, 24 Nov 2006 14:39:01 +0900

> This patch fixes mtu calculation of IPv4
> 
> ip_append_data should refer the mtu of "dst" not "path".
> if "dst" is stacked, "path" is the actual dst_entry in
> the routing table.
> therefore the mtu of "path" equals link mtu which is
> depends on the device so that it ignores the header length
> and the trailer length
> "dst" has mtu for creating packet.
> 
> Signed-off-by: Miika Komu <miika@iki.fi>
> Signed-off-by: Diego Beltrami <Diego.Beltrami@hiit.fi>
> Signed-off-by: Kazunori Miyazawa <miyazawa@linux-ipv6.org>

I'm not sure about this change.

If you look at the code in this function, "mtu" is always used with
adjustments via 'exthdrlen' (which is set to rt->u.dst.header_len).
So it seems the encapsulation is taken into account.

Perhaps any problem you are seeing is some artifact of the ipv6 in
ipv4 tunnel implementation.  Otherwise we'd have other reports of this
problem, wouldn't we?
