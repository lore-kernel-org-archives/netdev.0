From: David Miller <davem@davemloft.net>
Subject: Re: BUG: NIU driver: strange issues with multicast "UDP: short
 packet"
Date: Wed, 04 Feb 2009 01:34:31 -0800 (PST)
Message-ID: <20090204.013431.170274717.davem@davemloft.net>
References: <1233737704.20497.70.camel@localhost.localdomain>
	<20090204.010029.12969718.davem@davemloft.net>
	<1233739926.20497.78.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jdb@comx.dk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54400
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752132AbZBDJef (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2009 04:34:35 -0500
In-Reply-To: <1233739926.20497.78.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Dangaard Brouer <jdb@comx.dk>
Date: Wed, 04 Feb 2009 10:32:06 +0100

> On Wed, 2009-02-04 at 01:00 -0800, David Miller wrote:
> > At the point when IPMR is dealing with potentially forwarding
> > the frame, the UDP headers aren't yet pulled into the linear
> > area.  UDP input will do that with it's pskb_may_pull() call.
> 
> Can I get a little code hint, where IPMR is dealing with potentially
> forwarding the frame?

ip_mr_forward().

> Is there an easy way to test if the packet is corrupted?
> Can you recomment a way to test it?

If UDP header length field is > 2000, you've got a problem.
