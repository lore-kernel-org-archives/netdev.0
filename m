From: Ben Pfaff <blp@nicira.com>
Subject: Re: [ovs-dev] [GIT PULL v2] Open vSwitch
Date: Mon, 28 Nov 2011 15:14:24 -0800
Message-ID: <20111128231424.GT3003@nicira.com>
References: <20111123075433.GA7928@gondor.apana.org.au>
 <1322050976.2039.125.camel@mojatatu>
 <20111128130409.GB16828@gondor.apana.org.au>
 <1322488954.7338.66.camel@mojatatu>
 <20111128160117.GA6349@nicira.com>
 <1322518873.6118.7.camel@mojatatu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>, dev@openvswitch.org,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:40285 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751530Ab1K1XOa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2011 18:14:30 -0500
Received: by iage36 with SMTP id e36so9621157iag.19
        for <netdev@vger.kernel.org>; Mon, 28 Nov 2011 15:14:29 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1322518873.6118.7.camel@mojatatu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 28, 2011 at 05:21:13PM -0500, Jamal Hadi Salim wrote:
> On Mon, 2011-11-28 at 08:01 -0800, Ben Pfaff wrote:
> 
> > Regarding OpenFlow rate limiting, in addition to Martin's response, Open
> > vSwitch has implemented controller rate limiting since day one.  It is
> > documented in ovs-vswitchd.conf.db(5):
> 
> Ok, I think thats a good start. My experience says just rate limiting
> may not be sufficient - unless the rate limiting is adaptive in some
> form; or just use strict prio where you let the exception traffic
> rot if you have other work - maybe thats what Martin was talking 
> about.
> 
> The problem is more in the outbound towards the external controller.
> You dont have multiple queues (given a single TCP socket) and config,
> events, and exception packets are all shared in one queue.

I believe that Martin's point was that production controllers don't
usually get any packets to the controller at all, because they
configure the flow table to handle or drop all traffic.  Individual
flow table entries can direct traffic to the controller (subject
optionally to both Open vSwitch rate limiting of packets to the
controller and to any QoS policy for the controller connection), and
some controllers might use this feature to direct specific types of
traffic (e.g. LLDP) to the controller.

Open vSwitch doesn't limit a controller to a single OpenFlow TCP
connection.  A controller can set up multiple OpenFlow connections to
a single OVS bridge, use one of them for receiving packets, and use
the others for other purposes.  I don't know whether anyone does this,
because keeping the amount of traffic sent to the controller to a
minimum is effective in practice.
