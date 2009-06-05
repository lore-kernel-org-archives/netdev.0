From: Roland Dreier <rdreier@cisco.com>
Subject: Re: IPoIB: Fix multicast packet drops before join is complete
Date: Fri, 05 Jun 2009 09:56:00 -0700
Message-ID: <adaeitywrfj.fsf@cisco.com>
References: <alpine.DEB.1.10.0906021044430.15692@gentwo.org>
	<20090603.224104.222901210.davem@davemloft.net>
	<alpine.DEB.1.10.0906041150590.3204@gentwo.org>
	<20090604.153057.178458221.davem@davemloft.net>
	<alpine.DEB.1.10.0906050959380.23895@gentwo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	yosefe@Voltaire.COM
To: Christoph Lameter <cl@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-3.cisco.com ([171.71.176.72]:56765 "EHLO
	sj-iport-3.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752295AbZFEQz6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Jun 2009 12:55:58 -0400
In-Reply-To: <alpine.DEB.1.10.0906050959380.23895@gentwo.org> (Christoph
	Lameter's message of "Fri, 5 Jun 2009 10:18:15 -0400 (EDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


 > ARP is tied to managing small chunks of information about the network
 > infrastructure. Buffering the first few and throwing the rest away is
 > appropriate there for what the ARP protocol intends to do.

Yes, but what the IP stack is doing is queueing a few packets while ARP
is pending and dropping all other packets until the destination ethernet
address is resolved.

 > UDP multicasting can be used for streaming information. And right now the
 > IPoIB layer is dropping thousands of packets whenever there was a pause of
 > a few minutes or when a new multicast group is used and there is some
 > delay that the network need to reestablish the multicast route.

Yes -- and the required IB multicast resolution seems like it is an L2
thing precisely analogous to ARP.  So I think the original IPoIB code
actually was doing the right thing.

 - R.
