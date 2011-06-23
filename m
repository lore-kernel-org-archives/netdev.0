From: David Miller <davem@davemloft.net>
Subject: Re: unintended ipv4 broadcast policy change
Date: Thu, 23 Jun 2011 13:45:04 -0700 (PDT)
Message-ID: <20110623.134504.1261579649197526589.davem@davemloft.net>
References: <20110622.163935.2248705300315908767.davem@davemloft.net>
	<20110623081614.213a432f@nehalam.ftrdhcpuser.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.hengli.com.au, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:49791 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933925Ab1FWUpT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jun 2011 16:45:19 -0400
In-Reply-To: <20110623081614.213a432f@nehalam.ftrdhcpuser.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Thu, 23 Jun 2011 08:16:14 -0700

> On Wed, 22 Jun 2011 16:39:35 -0700 (PDT)
> David Miller <davem@davemloft.net> wrote:
> 
>> But debian definitely still has this bug.  On debian, as a result,
>> every packet received gets parsed.
> 
> Are you saying the DHCP client ends up parsing every packet?
> This doesn't appear to be true.
> 
> I checked and the dhclient spends its life waiting on select for DHCP port.

Which dhcp client do you have installed?  There are about 6 or 7 of
them available in debian.

Unless it closes the AF_PACKET socket after it gets a lease, it's
going to get every packet.  Because it uses a type argument of
"SOCK_PACKET" to the socket() call, the AF_PACKET layer will not use
the packet filter it installs during receive processing.

Check the source if you don't believe me, maybe whatever repo you're
using has different code in this area.
