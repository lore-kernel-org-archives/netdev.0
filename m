From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH net-next 00/10] NCSI Support
Date: Fri, 08 Jul 2016 08:05:39 +1000
Message-ID: <1467929139.27157.57.camel@kernel.crashing.org>
References: <1467523953-18998-1-git-send-email-gwshan@linux.vnet.ibm.com>
	 <577E921C.5050904@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, joel@jms.id.au, weixue@trustnetic.com
To: Florian Fainelli <f.fainelli@gmail.com>,
	Gavin Shan <gwshan@linux.vnet.ibm.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:60986 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751926AbcGGWF7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Jul 2016 18:05:59 -0400
In-Reply-To: <577E921C.5050904@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-07-07 at 10:32 -0700, Florian Fainelli wrote:
> 
> I know nothing about NCSI, pretty much like Jon Snow, but from a cursory
> look at your patches, is not there a way to make the NCSCI capable
> network devices strictly adhere to the net_device APIs and calling
> conventions?

They already do.

Basically imagine NC-SI being a replacement for the PHY of the device.

Instead of having a PHY, your MII is directly connected to another NIC
(the main system NIC) which conveniently provide that sideband MII
interface for you.

You then use the NC-SI protocol which uses a specific ethernet packet
type to communicate with that other NIC as you would otherwise communicate
with a PHY using MDIO. At least conceptually. For config. Normal traffic
is still normal ethernet.

The protocol is more complex than MDIO though, you can be connected to
multiple NICs, you have to provide your MAC address to the other guy so
he can route some incoming traffic to you etc...

So in the current implementation by Gavin, all that is needed for an
existing NIC driver to support NC-SI is a few lines of code to register
with the stack, which will under the hood create the ncsi_dev associated
with the net_dev and manage the protocol.

>From a "user" point of view you still have a normal netdev doing normal
ethernet, the NC-SI protocol is transparent and strictly used to maintain
the link active between you and the other NIC thorugh which your traffic
goes.

Cheers,
Ben.
