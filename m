From: David Lamparter <equinox@diac24.net>
Subject: Re: [BUG] bridge leaks 3 references on lo per up&down
Date: Wed, 28 Jul 2010 14:03:36 +0200
Message-ID: <20100728120336.GD13413@jupiter.n2.diac24.net>
References: <20100727152514.GA13413@jupiter.n2.diac24.net>
 <20100727100249.51ffc893@nehalam>
 <20100728074428.GB13413@jupiter.n2.diac24.net>
 <20100728095825.GC13413@jupiter.n2.diac24.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	bridge@lists.linux-foundation.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from spaceboyz.net ([87.106.131.203]:58113 "EHLO spaceboyz.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753164Ab0G1MDn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Jul 2010 08:03:43 -0400
Content-Disposition: inline
In-Reply-To: <20100728095825.GC13413@jupiter.n2.diac24.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 28, 2010 at 11:58:25AM +0200, David Lamparter wrote:
> unshare -n -- /bin/bash -c 'ip link add link lo veth0 type veth peer
>       name veth3 netns 1; brctl addbr br0; \
>       ip l s br0 up; sleep 8; ip l s br0 down; sleep 1;
>       ip l s br0 up; sleep 8;'
>
> I get "usage count = 7" on lo; when I add another up & down, I get
> "usage count = 10". 4 times makes it a merry 13 refs...

It only happens with BRIDGE_IGMP_SNOOPING. As we don't need that, our
"fix" is just to run with it disabled... works pretty fine.

Herbert, you implemented bridge multicast support, maybe you can figure
out where these references are taken?


-David

