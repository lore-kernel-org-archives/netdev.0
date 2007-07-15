From: Patrick McHardy <kaber@trash.net>
Subject: Re: [Bugme-new] [Bug 8755] New: "ip -6 route change " behaves like
 "ip -6 route add"
Date: Sun, 15 Jul 2007 17:07:26 +0200
Message-ID: <469A382E.6000104@trash.net>
References: <bug-8755-10286@http.bugzilla.kernel.org/> <20070714214731.baf38cb8.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	"bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@kernel-bugs.osdl.org>
To: bugzilla@fire.lp0.eu
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59584 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756762AbXGOPIg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Jul 2007 11:08:36 -0400
In-Reply-To: <20070714214731.baf38cb8.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Morton wrote:
> On Sat, 14 Jul 2007 15:21:21 -0700 (PDT) bugme-daemon@bugzilla.kernel.org wrote:
> 
>>The "ip -6 route change" command behaves as though "ip -6 route add" was used.
>>The source of iproute2 shows that "change" uses the "NLM_F_REPLACE" netlink
>>flag only.
>>
>>ip utility, iproute2-ss070313
>>
>>Changing an existing route:
>># ip -6 r show 2002::/16
>>2002::/16 dev sit0  metric 1024  expires 4482618sec mtu 1480 advmss 7140
>>hoplimit 4294967295
>># ip -6 r change 2002::/16 dev sit0 mtu 1280
>>RTNETLINK answers: File exists
>>
>>Adding a route using "change":
>># ip -6 r change 2002::/17 dev sit0 mtu 1280
>># ip -6 r show 2002::/17
>>2002::/17 dev sit0  metric 1024  expires 21334368sec mtu 1280 advmss 1220
>>hoplimit 4294967295


There is a difference between "add" and "change". "add" will only add a
new address if there isn't already one with the same identity, "change"
will allow to change attributes of an existing address, like flags,
lifetime, ..., or behave similar to "add" in case the address doesn't
already exist.

What kind of behaviour are you expecting?

