From: Patrick McHardy <kaber@trash.net>
Subject: Re: one more... iproute commands lockup whole system
Date: Wed, 04 Apr 2007 15:36:54 +0200
Message-ID: <4613A9F6.8000307@trash.net>
References: <20070321175951.M73913@visp.net.lb> <46026717.9060909@trash.net>	 <20070322124533.M79867@visp.net.lb> <46027FF2.6020001@trash.net>	 <20070322101224.3e6bb899@freekitty>  <20070404000054.M58020@visp.net.lb>	 <1175649016.3957.10.camel@localhost> <461301C0.2050409@trash.net>	 <20070404020622.M69215@visp.net.lb> <1175684114.4088.12.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Denys <denys@visp.net.lb>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59164 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753805AbXDDNg5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Apr 2007 09:36:57 -0400
In-Reply-To: <1175684114.4088.12.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal wrote:
> On Wed, 2007-04-04 at 05:11 +0300, Denys wrote:
> 
>>I think this highly useful feature given by jamal, difficult to be avoided 
>>from crash, if user not enough experienced in networking(like me). I guess 
>>packet can be even not ipv4/ipv6 packet, maybe it can be cloned IPX or ARP, 
>>so TTL field cannot be used.


We have a loop counter (RTTL) in tc_verd. For some reason it is reset
after ing_filter though.

> I checked maybe sk_buff have some fields, seems 
>>also bad luck, if there can be something like "internal" counter for packet, 
>>how much times it got redirected, it will help. 
> 
> 
> Adding a field in the skb that keeps track of things would work well,
> but would be a controvesial thing to do because it actually requires a
> vector not just one field. There is a filed called cb[] but it cant be
> used in this case because every time we redirect it could be trampled.


It would be interesting to find out what the problem is exactly.
The configuration itself looks harmless, so I'm guessing its
rather a deadlock than a loop.
