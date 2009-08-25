From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: UDP multicast packet loss not reported if TX ring overrun?
Date: Tue, 25 Aug 2009 12:36:29 -0400 (EDT)
Message-ID: <alpine.DEB.1.10.0908251230430.26329@gentwo.org>
References: <alpine.DEB.1.10.0908171548040.20399@gentwo.org>  <4A89C026.4030402@us.ibm.com>  <alpine.DEB.1.10.0908171642500.20399@gentwo.org>  <1250545839.25939.21.camel@w-sridhar.beaverton.ibm.com>  <alpine.DEB.1.10.0908171813070.15956@gentwo.org>
 <1250549034.25939.30.camel@w-sridhar.beaverton.ibm.com>  <alpine.DEB.1.10.0908171848370.15956@gentwo.org> <1250554332.25939.46.camel@w-sridhar.beaverton.ibm.com> <alpine.DEB.1.10.0908241334230.30487@gentwo.org> <4A930DEF.5000008@gmail.com>
 <alpine.DEB.1.10.0908250945460.5972@gentwo.org> <4A93EB9B.5020600@gmail.com> <alpine.DEB.1.10.0908250958540.28552@gentwo.org> <4A9403F0.2060301@gmail.com> <alpine.DEB.1.10.0908251135380.26329@gentwo.org> <4A940A10.60607@gmail.com> <alpine.DEB.1.10.0908251203220.26329@gentwo.org>
 <4A9410E9.6090602@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Sridhar Samudrala <sri@us.ibm.com>,
	Nivedita Singhvi <niv@us.ibm.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4.ultrahosting.com ([74.213.175.253]:50760 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754875AbZHYQgq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2009 12:36:46 -0400
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id DF77682CE2D
	for <netdev@vger.kernel.org>; Tue, 25 Aug 2009 12:37:40 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.253])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id mgmyN3d3AMv0 for <netdev@vger.kernel.org>;
	Tue, 25 Aug 2009 12:37:40 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id C9C7282CE43
	for <netdev@vger.kernel.org>; Tue, 25 Aug 2009 12:37:22 -0400 (EDT)
In-Reply-To: <4A9410E9.6090602@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 25 Aug 2009, Eric Dumazet wrote:

> > I read this just yesterday. IP_RECVERR means that the application wants to
> > see details on each loss. We just want some counters that give us accurate
> > statistics to gauge where packet loss is occurring. Applications are
> > usually not interested in tracking the fate of each packet.
>
> Yep,  but IP_RECVERR also has the side effect of letting kernel returns -ENOBUFS error
> in sending and congestion, which was your initial point :)

The initial point was that the SNMP counters are not updated if IP_RECVERR
is not set which is clearly a bug and your and my patch addresses that.

Then Sridhar noted that there are other tx drop counters. qdisc counters
are also not updated. Wish we would maintain tx drops counters there as
well so that we can track down which NIC drops it.

Then came the wishlist of UDP counters for tx drops and socket based
tx_drop accounting for tuning and tracking down which app is sending
too fast .... ;-)

The apps could be third party apps. Just need to be able to troubleshoot
packet loss.





