From: Benjamin Poirier <benjamin.poirier@gmail.com>
Subject: Re: More details on why received UDP packets are treated as errors?
Date: Tue, 30 Jul 2013 16:38:10 -0400
Message-ID: <20130730203810.GC24932@d2.synalogic.ca>
References: <51F6B2AB.5050607@candelatech.com>
 <1375129292.10515.21.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Greear <greearb@candelatech.com>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f178.google.com ([209.85.216.178]:48633 "EHLO
	mail-qc0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757122Ab3G3UiO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jul 2013 16:38:14 -0400
Received: by mail-qc0-f178.google.com with SMTP id s1so1519788qcw.37
        for <netdev@vger.kernel.org>; Tue, 30 Jul 2013 13:38:13 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1375129292.10515.21.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/07/29 13:21, Eric Dumazet wrote:
> On Mon, 2013-07-29 at 11:21 -0700, Ben Greear wrote:
> > We have a test case on 3.9.9+ (local patches applied) where sending from
> > VETH interface, through peer VETH bridged (with our own emulator bridge module)
> > to physical interface, which is then looped to another physical interface (B).
> > The VETH and the wired B interface are sending UDP traffic to each other.
> > Routing rules should be configured such that this all works appropriately.
> > 
> > Replacing our bridging module with a user-space bridge has same behaviour.
> > 
> > This setup works on the 3.7.y kernel, but we only get one-way traffic
> > (B to VETH) on 3.9.9+.
> > 
> > I sniffed the B port, and traffic appears to be sent and received
> > properly (ie, no checksum errors, etc).  But, our user-space app
> > shows no received UDP frames on B, and netstat -s gives the
> > output below.
> > 
> > Is there any way to get more details about what these 'packet receive errors'
> > are caused by using normal-ish tools?
> 
> You could try dropwatch for this kind of obscure drops
> 
> https://fedorahosted.org/dropwatch/

If the drop happens in __udp_queue_rcv_skb() you can also get some info from
the udp_fail_queue_rcv_skb tracepoint. See "296f7ea udp: add tracepoints for
queueing skb to rcvbuf (v3.1-rc1)".
