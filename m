From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 1/3] Rough VJ Channel Implementation - vj_core.patch
Date: Wed, 26 Apr 2006 15:40:50 -0700 (PDT)
Message-ID: <20060426.154050.74768269.davem@davemloft.net>
References: <54AD0F12E08D1541B826BE97C98F99F143AE6C@NT-SJCA-0751.brcm.ad.broadcom.com>
	<444FCE32.2010207@garzik.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: caitlinb@broadcom.com, kelly@au1.ibm.com, netdev@vger.kernel.org,
	rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:55007
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932422AbWDZWlL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Apr 2006 18:41:11 -0400
To: jeff@garzik.org
In-Reply-To: <444FCE32.2010207@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jeff Garzik <jeff@garzik.org>
Date: Wed, 26 Apr 2006 15:46:58 -0400

> Oh, there are plenty of examples of filtering within an established 
> connection:  input rules.  I've seen "drop all packets from <these> IPs"
> type rules frequently.  Victims of DoS use those kinds of rules to stop 
> packets as early as possible.

Yes, good point, but this applies to listening connections.

We'll need to figure out a way to deal with this.

It occurs to me that for established connections, netfilter can simply
remove all matching entries from the netchannel lookup tables.

But that still leaves the thorny listening socket issue.  This may
by itself make netfilter netchannel support important and that brings
up a lot of issues about classifier algorithms.

All of this I wanted to avoid as we start this work :-)

We can think about how to approach these other problems and start
with something simple meanwhile.  That seems to me to be the best
approach moving forward.

It's important to start really simple else we'll just keep getting
bogged down in complexity and details and never implement anything.
