From: Julian Anastasov <ja@ssi.bg>
Subject: Re: net/ipv4/route.c: Routing anomaly introduced by 89aef89 (ipv4:
 Delete routing cache.)
Date: Tue, 9 Jul 2013 08:43:14 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1307090832450.1621@ja.ssi.bg>
References: <20130708113457.4a0d6023@pluto>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	netdev@vger.kernel.org, eyal.birger@gmail.com
To: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:44235 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751500Ab3GIFhh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Jul 2013 01:37:37 -0400
In-Reply-To: <20130708113457.4a0d6023@pluto>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Mon, 8 Jul 2013, Shmulik Ladkani wrote:

> Hi,
> 
> In 89aef89 (ipv4: Delete routing cache) the following was removed from
> ip_route_input_common (nowadays named ip_route_input_noref):
> 
> -       tos &= IPTOS_RT_MASK;
> 
> As a side effect, the 'tos' argument passed to 'ip_route_input_slow' is
> the "raw" u8, as present in iph->tos (opposed to the formerly "masked"
> value).
> 
> This may affect the route calculation, as this value is later placed in
> fl4.flowi4_tos for matching purposes (using equality to the tos stored
> in the FIB Rule and/or Route).
> 
> (BTW, the question whether applying the historical IPTOS_RT_MASK
> prior route lookup is interesting on its own...)
> 
> However, 89aef89 created an anomaly - since in the output path, routing
> *still* uses the IPTOS_RT_MASK (see __ip_route_output_key for example).
> 
> It seems the omission of 'tos &= IPTOS_RT_MASK' from
> 'ip_route_input_noref' was accidental.

	Agreed

> We should align input/output behavior by reverting the omission, or
> alternatively we may reconsider the entire IPTOS_RT_MASK thing.

	The right thing should be to use tos &= IPTOS_RT_MASK
at beginning of ip_route_input_noref.

Regards

--
Julian Anastasov <ja@ssi.bg>
