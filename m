From: Brian Haley <brian.haley@hp.com>
Subject: Re: [IPv6] Fix ICMPv6 redirect handling with target multicast address
Date: Tue, 02 Oct 2007 17:06:08 -0400
Message-ID: <4702B2C0.2070004@hp.com>
References: <OF939F3A2D.96830882-ON88257368.007068EA-88257368.007161DC@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	netdev-owner@vger.kernel.org,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel7.hp.com ([156.153.255.213]:46697 "EHLO atlrel7.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753574AbXJBVGL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Oct 2007 17:06:11 -0400
In-Reply-To: <OF939F3A2D.96830882-ON88257368.007068EA-88257368.007161DC@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

David Stevens wrote:
>         ipv6_addr_type() returns a mask, so checking for equality will 
> fail to
> match if  any other (irrelevant) attributes are set. How about using 
> bitwise
> operators for that?

ipv6_addr_type() does return a mask, but there's a lot of code that just 
checks for equality since some things are mutually-exclusive - this code 
is actually identical to what ip6_route_add() does.  I don't 
particularly like this duality, but it's there - I'd gladly volunteer to 
clean this up everywhere if I didn't think there might be some 
performance reason it was done like that.

> Also, the error message is no longer descriptive of the
> failure if it's a link-local multicast, but you could make it "target 
> address is not
> link-local unicast.\n" (in both places).

I can do that, thanks.

-Brian
