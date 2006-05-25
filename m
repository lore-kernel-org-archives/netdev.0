From: Patrick McHardy <kaber@trash.net>
Subject: Re: sky2 hw csum failure [was Re: sky2 large MTU problems]
Date: Thu, 25 May 2006 13:15:39 +0200
Message-ID: <447591DB.2020901@trash.net>
References: <6278d2220605240228v576dd66atdad4855b308e64bf@mail.gmail.com>	 <20060524103820.2e213a0b@localhost.localdomain>	 <44758881.1020106@trash.net> <6278d2220605250355y316f974cl216f22d198475666@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>, netdev@vger.kernel.org,
	Netfilter Developer <netfilter-devel@lists.netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:63364 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S965101AbWEYLPt
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 May 2006 07:15:49 -0400
To: Daniel J Blueman <daniel.blueman@gmail.com>
In-Reply-To: <6278d2220605250355y316f974cl216f22d198475666@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Daniel J Blueman wrote:
> On 25/05/06, Patrick McHardy <kaber@trash.net> wrote:
> 
>> Daniel, is there an easy way to reproduce the checksum failure?
> 
> 
> In short, no. This was seen when packets may have been truncated by
> large MTU (eg 9000) problems in the sky2 driver transmit path.
> 
> There is a small chance that this could relate to transmitting with an
> MTU of 9000 (possibly with receiving with an MTU of 1500 too)

Unfortunately I can't test this myself because my other NICs don't
support MTUs > 1500.

> On that interface, the only rules that were being exercised were:
> 
> iptables -t filter -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
> iptables -t filter -A INPUT -p tcp -m tcp --dport 445 --syn -j ACCEPT # SMB
> iptables -t filter -A INPUT -j DROP

That shouldn't cause any packet modifications. Can you trigger the
checksum failures without netfilter?

