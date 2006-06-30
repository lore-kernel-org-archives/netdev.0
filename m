From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 2/3] [VLAN]: Update iif when receiving via VLAN device
Date: Fri, 30 Jun 2006 18:32:29 +0200
Message-ID: <20060630163229.GH14627@postel.suug.ch>
References: <20060629085111.GY1376@postel.suug.ch> <1151623394.8922.27.camel@jzny2> <20060629233933.GB14627@postel.suug.ch> <1151625826.8922.58.camel@jzny2> <20060630004640.GC14627@postel.suug.ch> <1151629890.8922.121.camel@jzny2> <20060630130811.GE14627@postel.suug.ch> <1151675843.5270.18.camel@jzny2> <20060630141531.GG14627@postel.suug.ch> <1151678118.5270.45.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:34232 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S932790AbWF3QcI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jun 2006 12:32:08 -0400
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1151678118.5270.45.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* jamal <hadi@cyberus.ca> 2006-06-30 10:35
> On Fri, 2006-30-06 at 16:15 +0200, Thomas Graf wrote:
> > eth0::tcf_mirred()     skb->dev = ifb0, input_dev = eth0
> > ifb0::tcf_mirred()     skb->dev = ifb1, input_dev = ifb0
> > ifb1::ifb_xmit()       skb->dev = ifb0, input_dev = ifb1, set ncls bit
> > ifb0::ifb_xmit()       skb->dev = ifb1, input_dev = ifb0
> > ifb1::ifb_xmit()       skb->dev = ifb0, input_dev = ifb1
> > ...
> > 
> > Oh dear... and we don't even have a ttl to catch this.
> > 
> 
> Did you actually try to run this before you reached this conclusion?

I did, fortunately some other bug prevents this from happening,
packets are simply dropped somewhere.

> With all due respect, the architecture works. I have invested many many
> hours testing and verifying. There may be coding bugs - and those need
> fixing. Kill the bugs.

Right, just run this

tc filter add dev eth0 parent 1: protocol ip prio 10
              u32 match ip tos 0 0 flowid 1:1
	      action mirred egress redirect dev ifb1
tc filter add dev ifb1 parent 1: protocol ip prio 10
              u32 match ip tos 0 0 flowid 1:1
	      action mirred egress redirect dev ifb0


Anyways, I give up. Last time I've been running after you trying
to fix the many bugs you leave behind. Ever noticed that whenever
you add some new code it's someone else following up with tons of
small bugfix patches having a hard time trying to figure out the
actual intent. I'll just duplicate the code for my purpose, so
much easier.
