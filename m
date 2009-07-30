From: Roland Dreier <rdreier@cisco.com>
Subject: Re: IPv6 default routes timing out?
Date: Thu, 30 Jul 2009 11:34:21 -0700
Message-ID: <aday6q6qatu.fsf@cisco.com>
References: <874osv8jyo.fsf@shaolin.home.digitalvampire.org>
	<1248914038.13447.17.camel@merlyn>
	<87k51q6raq.fsf@shaolin.home.digitalvampire.org>
	<1248975058.7167.28.camel@Maple>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Roland Dreier <roland@digitalvampire.org>, netdev@vger.kernel.org
To: John Dykstra <john.dykstra1@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:53371 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750804AbZG3SeW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2009 14:34:22 -0400
In-Reply-To: <1248975058.7167.28.camel@Maple> (John Dykstra's message of "Thu,
	30 Jul 2009 12:30:58 -0500")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


 > > Thanks, I did some more debugging it seems the issue is in the
 > > router's (openbsd) wireless driver -- it thinks it is broadcasting
 > > router advertisements but they aren't making it to the laptop.

 > Could it be that there's something buggy in the laptop wireless driver
 > or hardware re filtering of multicast packets at the L2 level? 

Well, I see router advertisements (and pings to ff02::1) from the router
on both of the two laptops I have handy, and then after a while the
openbsd system seems to stop broadcasting -- I no longer see the
broadcast ipv6 packets on either laptop, but if I just do "ifconfig ral0
down; ifconfig ral0 up" on the openbsd system then everything seems to
come back.  So it seems unlikely that the problem is anywhere except on
the openbsd system sending.

It's interesting to note that the only broadcasts that the openbsd
router is going to send that matter in my setup are ipv6 router
advertisements -- before I started using ipv4, all the broadcasts would
have been arps from the laptops to the router, so I would have never
noticed that the router stopped being able to broadcast.

 - R.
