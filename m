From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv4/icmp: redirect messages can use the ingress
 daddr as source
Date: Mon, 12 Oct 2015 19:38:15 -0700 (PDT)
Message-ID: <20151012.193815.2255829332660714250.davem@davemloft.net>
References: <d10d2ec1cdf0334e9951b819051d4a127e103091.1444385951.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, corbet@lwn.net, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net
To: pabeni@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43103 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932148AbbJMCWQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2015 22:22:16 -0400
In-Reply-To: <d10d2ec1cdf0334e9951b819051d4a127e103091.1444385951.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paolo Abeni <pabeni@redhat.com>
Date: Fri,  9 Oct 2015 14:34:31 +0200

> This patch allows configuring how the source address of ICMP
> redirect messages is selected; by default the old behaviour is
> retained, while setting icmp_redirects_use_orig_daddr force the
> usage of the destination address of the packet that caused the
> redirect.
> 
> The new behaviour fits closely the RFC 5798 section 8.1.1, and fix the
> following scenario:
> 
> Two machines are set up with VRRP to act as routers out of a subnet,
> they have IPs x.x.x.1/24 and x.x.x.2/24, with VRRP holding on to
> x.x.x.254/24.
> 
> If a host in said subnet needs to get an ICMP redirect from the VRRP
> router, i.e. to reach a destination behind a different gateway, the
> source IP in the ICMP redirect is chosen as the primary IP on the
> interface that the packet arrived at, i.e. x.x.x.1 or x.x.x.2.
> 
> The host will then ignore said redirect, due to RFC 1122 section 3.2.2.2,
> and will continue to use the wrong next-op.
> 
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>

Applied to net-next, thanks.
