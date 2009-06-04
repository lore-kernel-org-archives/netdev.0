From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: IPoIB: Fix multicast packet drops before join is complete
Date: Thu, 4 Jun 2009 11:52:48 -0400 (EDT)
Message-ID: <alpine.DEB.1.10.0906041150590.3204@gentwo.org>
References: <alpine.DEB.1.10.0906021044430.15692@gentwo.org> <20090603.224104.222901210.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: rdreier@cisco.com, netdev@vger.kernel.org, yosefe@Voltaire.COM
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp3.ultrahosting.com ([74.213.175.254]:40249 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754177AbZFDPxE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2009 11:53:04 -0400
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 7AA4D82CD6E
	for <netdev@vger.kernel.org>; Thu,  4 Jun 2009 12:07:59 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id E-4lBzZBshhm for <netdev@vger.kernel.org>;
	Thu,  4 Jun 2009 12:07:50 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id E646F82CD93
	for <netdev@vger.kernel.org>; Thu,  4 Jun 2009 12:07:49 -0400 (EDT)
In-Reply-To: <20090603.224104.222901210.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 3 Jun 2009, David Miller wrote:

> I don't think using an infinite backlog for this is wise.

The number of packets is limited by the size of the sendbuffer. Its not
unlimited but under user control.

> We don't do this for ARP, for example.  We have a 3 packet limit just
> like IPoIB implements for multicast here.

ARP is a management protocol with specific semantics. Socket protocols are
dealing with streams of datagrams.

> I'm all for increasing those limits, but eliminating them I cannot
> agree with.

If these limits are lower than the socket sendbuffer size then the packets
will be dropped without the app being stopped. If they are set higher then
the application will block after the sendbuffer size has been reached.


