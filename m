From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] iproute2: ip: add wilcard support for device matching
Date: Fri, 17 Dec 2010 08:38:08 -0500
Message-ID: <1292593088.2668.43.camel@mojatatu>
References: <1291993092-8675-1-git-send-email-opurdila@ixiacom.com>
	 <201012101932.59352.opurdila@ixiacom.com>
	 <1292002959.3580.321.camel@edumazet-laptop>
	 <201012102006.03401.opurdila@ixiacom.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org,
	Lucian Adrian Grijincu <lucian.grijincu@gmail.com>,
	Vlad Dogaru <ddvlad@rosedu.org>
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:63586 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754425Ab0LQNiG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Dec 2010 08:38:06 -0500
Received: by ywl5 with SMTP id 5so311716ywl.19
        for <netdev@vger.kernel.org>; Fri, 17 Dec 2010 05:38:05 -0800 (PST)
In-Reply-To: <201012102006.03401.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2010-12-10 at 20:06 +0200, Octavian Purdila wrote:

> > $ ip link add link bond0 "vlan\*199" type vlan id 199
> > $ ifconfig "vlan\*199"
> 
> :) Then use a special dev keyword like dev* ?
> 
> $ ip link set dev* dummy set
> 
> Or use a new flag to allow expansion?
> 
> $ ip -e link set dev dummy* set

There was something ive always wanted to do but
havent had time. It will cut time in a big way the
user-kernel interaction in precisely your situation.

Add a new general purpose netdev 32 bit tag. You can use this
feature to "group" netdevs. The group "all netdevs" is 0 - which
is the default.
I can group individual dummy interfaces into group 1. 
ip link dev dummy0 set group 1
..
..
ip link dev dummy99 set group 1

Then i can send a query to only ifup and ignore
the 1000 vlans that exist.

ip link dev ls group 1

or if i didnt list the group, then group 0 is assumed.

As a warning - this would be a general purpose tag.
So i can use it in conjunction with skb->mark to enable
filtering for example on ingress side with some action.

cheers,
jamal

