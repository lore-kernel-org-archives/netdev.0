From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] net: Fix RPF to work with policy routing
Date: Fri, 23 Oct 2009 06:51:15 -0400
Message-ID: <1256295075.6264.59.camel@dogo.mojatatu.com>
References: <1255867954.4815.25.camel@dogo.mojatatu.com>
	 <1255868019.4815.27.camel@dogo.mojatatu.com>
	 <20091022.214943.105371652.davem@davemloft.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, atis@mikrotik.com, eric.dumazet@gmail.com,
	zenczykowski@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.24]:33081 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751041AbZJWKyW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2009 06:54:22 -0400
Received: by qw-out-2122.google.com with SMTP id 9so1333461qwb.37
        for <netdev@vger.kernel.org>; Fri, 23 Oct 2009 03:54:27 -0700 (PDT)
In-Reply-To: <20091022.214943.105371652.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2009-10-22 at 21:49 -0700, David Miller wrote:

> Such a change has a built-in assumption, I think, that
> marks are symmetric.

Only if the admin said they are symetric (by jumping
a few hoops).  In otherwise, I may intentionaly want
them to be symetric and use policy routing. I cant today.

> Just because we ended up with mark X on input doesn't mean
> that the reverse path route exists with mark X too.
>
> In fact I can't even see a valid way to specify a mark for
> the RPF lookup.

with the ipt or skbedit actions or via netfilter i could
set marks which could be as trivial as "set mark X if packet 
came in via eth0 or eth1 and mark Y if they came in via gre0"

> Maybe you can convince me otherwise :-)

Ok, let me try ;-> 

First let me say that it is _non-trivial_ for a packet to be 
policy-routing-RPF-dropped even with this patch. Youd have to do at
least 3 things to achieve that goal:
a) mark the packet on ingress 
b) have a  blackhole route in the policy routing table as the fall
through match and 
c) turn on rpf.

If someone goes that far to install policies, their intent could be
judged to mean they are serious about using RPF with policy routing.
If any of the above 3 conditions are not true then things continue to
work as is today.
IOW, if i set all those 3 conditions above then my expectation is the
system should not let in a packet if the policy routing table says no.
My intent is not to use the main table or some default route in the main
table; i really meant to use that policy routing table.

cheers,
jamal

