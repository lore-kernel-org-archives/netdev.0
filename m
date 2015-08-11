From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [net-next PATCH 1/3] net: make default tx_queue_len
 configurable
Date: Tue, 11 Aug 2015 17:48:07 +0200
Message-ID: <20150811174807.3e00b4da@redhat.com>
References: <1438203103-27013-2-git-send-email-phil@nwl.cc>
	<20150729210618.GF32705@breakpoint.cc>
	<20150729213428.GC15554@orbit.nwl.cc>
	<20150729.143731.834219016906219771.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: phil@nwl.cc, fw@strlen.de, netdev@vger.kernel.org,
	cwang@twopensource.com, eric.dumazet@gmail.com, brouer@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44955 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965045AbbHKPsJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Aug 2015 11:48:09 -0400
In-Reply-To: <20150729.143731.834219016906219771.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Wed, 29 Jul 2015 14:37:31 -0700 (PDT) David Miller <davem@davemloft.net> wrote:
[...]
> Which is that there are devices (virtual or whatever) which don't want
> a qdisc attached no matter what.  Flag those devices as such and
> adjust the qdisc attachment logic to check that new flag.

I agree on the approach DaveM are suggesting.

But virtual devices must support getting a qdisc attached.  I know of
many companies depending on this behavior.   Some times people just get
hit by this "strange" zero len issues when they happen to use
pfifo_fast as leaf node.


> Anything is better than hacking the queue len.

The hole problem comes from the double meaning of the queue len. e.g.
that value 0 have special meaning, but only during assigning the
default qdisc.  And pfifo_fast will use queue len zero if assigned.

(proposed solution:)

As DaveM also suggested, I would likely use a device flag to indicate
the device does not require any qdisc, and not assign any qdisc
(actually "noqueue") in case the default qdisc is chosen for this
device.

This should solve the problem for veth. And then we should cleanup all
the virtual devices, adding this flag and changing the
dev->tx_queue_len to the default value (e.g. remove setting it to zero).

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
