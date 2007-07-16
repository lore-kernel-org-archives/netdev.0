From: Patrick McHardy <kaber@trash.net>
Subject: Re: [Bugme-new] [Bug 8755] New: "ip -6 route change " behaves like
 "ip -6 route add"
Date: Mon, 16 Jul 2007 15:01:49 +0200
Message-ID: <469B6C3D.3070807@trash.net>
References: <bug-8755-10286@http.bugzilla.kernel.org/> <20070714214731.baf38cb8.akpm@linux-foundation.org> <469A382E.6000104@trash.net> <469A6C23.60206@simon.arlott.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	"bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@kernel-bugs.osdl.org>
To: Simon Arlott <simon@fire.lp0.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:49733 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756696AbXGPNDX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jul 2007 09:03:23 -0400
In-Reply-To: <469A6C23.60206@simon.arlott.org.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Simon Arlott wrote:
> On 15/07/07 16:07, Patrick McHardy wrote:
> 
>>>>Changing an existing route:
>>>># ip -6 r show 2002::/16
>>>>2002::/16 dev sit0  metric 1024  expires 4482618sec mtu 1480 advmss 7140
>>>>hoplimit 4294967295
>>>># ip -6 r change 2002::/16 dev sit0 mtu 1280
>>>>RTNETLINK answers: File exists
> 
> ^ This is clearly a bug, since I'm trying to change an existing route
> and it gives an error as if it tried to add it.


Agreed.

>>>>Adding a route using "change":
>>>># ip -6 r change 2002::/17 dev sit0 mtu 1280
>>>># ip -6 r show 2002::/17
>>>>2002::/17 dev sit0  metric 1024  expires 21334368sec mtu 1280 advmss 1220
>>>>hoplimit 4294967295
> 
> ^ This shouldn't be possible!


That one will probably be impossible to fix since IPv6 has never checked
for NLM_F_EXCL, doing to now might break things.

>>There is a difference between "add" and "change". "add" will only add a
>>new address if there isn't already one with the same identity, "change"
>>will allow to change attributes of an existing address, like flags,
>>lifetime, ..., or behave similar to "add" in case the address doesn't
>>already exist.
>>
>>What kind of behaviour are you expecting?
> 
> 
> That "change" would actually change not simply add. It won't let me
> change anything and in fact can only add instead.


The code looks like it would support it properly. Please add a
few printks to inet6_rtm_newaddr to find out what goes wrong.

> Compare it to ipv4 where "change" never adds - "replace" is "change, or
> add". (Also, "replace" doesn't work for v6 either).


IPv4 doesn't check any netlink flags, so I don't think that is correct.
