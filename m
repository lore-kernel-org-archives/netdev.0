From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [RFC PATCH net-next] bridge: Add bridge port learn filter and
 priority
Date: Mon, 23 Jun 2014 14:19:15 -0700
Message-ID: <20140623141915.3310c3b8@nehalam.linuxnetplumber.net>
References: <1403075767-31908-1-git-send-email-roopa@cumulusnetworks.com>
	<20140618133405.515b3741@nehalam.linuxnetplumber.net>
	<53A896A0.2030509@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: roopa@cumulusnetworks.com, davem@davemloft.net,
	netdev@vger.kernel.org, scotte@cumulusnetworks.com,
	ddutt@cumulusnetworks.com, shm@cumulusnetworks.com,
	nolan@cumulusnetworks.com, sfeldma@cumulusnetworks.com,
	jhs@mojatatu.com
To: Wilson Kok <wkok@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:32969 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754548AbaFWVTT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jun 2014 17:19:19 -0400
Received: by mail-pd0-f173.google.com with SMTP id r10so6105179pdi.18
        for <netdev@vger.kernel.org>; Mon, 23 Jun 2014 14:19:18 -0700 (PDT)
In-Reply-To: <53A896A0.2030509@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 23 Jun 2014 14:05:36 -0700
Wilson Kok <wkok@cumulusnetworks.com> wrote:

> On 6/18/14, 1:34 PM, Stephen Hemminger wrote:
> > On Wed, 18 Jun 2014 00:16:07 -0700
> > roopa@cumulusnetworks.com wrote:
> >
> >> One such topology is when there are multiple paths to a dual-homed host.
> > That is called a loop.
> > Loops are not allowed on bridge networks.
> > Sorry, this is just the kind of things spanning tree and TRILL were supposed
> > to address. Solving in local bridge is not a good idea.
> 
> This is not a loop situation.  The topology we're referring to is a 
> multi-chassis LAG topology (a widely supported feature by networking 
> vendors, e.g. Arista's MLAG and Cisco's VPC), where some hosts are 
> dual-homed on a pair of switches, and some hosts are single-homed on one 
> of the two switches, and there is a inter-chassis link between the 
> switches.  A dual-homed host can and will source packets from either or 
> both its uplinks with the same source MAC address. The packets may be 
> locally forwarded on the first hop switch, and they may also cross the 
> inter-chassis link from one switch to the other switch, e.g. in a 
> multicast or flood situation or just unicast to a single-homed host 
> connected to the other switch.  As such, the host's source MAC can be 
> learned on the inter-chassis link or the host link, and can move between 
> the two.  A dual-homed host may receive packets from either or both it's 
> uplinks, and in some cases it may receive duplicate copies of the same 
> packet.
> 

Isn't this bridging over a bond (or team) interface.
The point is this really shouldn't be part of bridge code.
