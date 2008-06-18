From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: RE: packetloss, on e1000e worse than r8169?
Date: Tue, 17 Jun 2008 17:58:00 -0700
Message-ID: <36D9DB17C6DE9E40B059440DB8D95F52056AD09B@orsmsx418.amr.corp.intel.com>
References: <20080616193501.M64730@visp.net.lb> <36D9DB17C6DE9E40B059440DB8D95F52056AC4C2@orsmsx418.amr.corp.intel.com> <200806170946.17351.denys@visp.net.lb> <200806172022.20720.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: "Denys Fedoryshchenko" <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:55724 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758546AbYFRA6D convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2008 20:58:03 -0400
Content-class: urn:content-classes:message
In-Reply-To: <200806172022.20720.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Denys Fedoryshchenko wrote:
> More info. Now it is peak time, and flow control disabled. Before it
> was 1% packetloss on small packets and 5-6% on large, now it is 0.3%
> on small, 1-2% on large. The flow-control required on this particular
> setup (probably linksys switches is too much crappy, no idea), and
> without it i experience "small" packetloss"   
> But seems on this motherboard, by some reasons flow-control not
> working, maybe it is related to PBA. 
> 
> I will try to play with PBA now, but not sure i can do that.

yes, on ICH8 playing with PBA will not give you much, ICH8 was meant to
be a "client" part and so sacrificed some FIFO space to save cost/power.

Also, our adapters support variable flow control thresholds (but we have
no good way to tune), it could be that your length of wire to your
switch or the switch itself takes too long to respond to flow control.

This would mean that too many packets get enqueued to the wire/hardware
before the flow control gets reacted to at the switch.

the registers are FCRTL and FCRTH, the numbers are in bytes, the
hardware sends a flow control STOP (txoff) packet when the FIFO fullness
goes past FCRTH, and sends flow control GO (txon) packet when threshold
drops below FCRTL.

Maybe that will help, let me know what else I can help with.
