From: David L Stevens <david.stevens@oracle.com>
Subject: Re: [PATCHv6 net-next 2/3] sunvnet: allow admin to set sunvnet MTU
Date: Thu, 18 Sep 2014 09:10:40 -0400
Message-ID: <541AD9D0.2010007@oracle.com>
References: <541A22FC.20407@oracle.com> <C383AC6E-F0A2-4510-8EC6-0EC606870249@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Raghuram Kothakota <Raghuram.Kothakota@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:24163 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752778AbaIRNKn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Sep 2014 09:10:43 -0400
In-Reply-To: <C383AC6E-F0A2-4510-8EC6-0EC606870249@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 09/18/2014 12:19 AM, Raghuram Kothakota wrote:

> 
> FYI, LDoms manager provides the maximum MTU of packets allowed for
> a vnet device in the "virtual-device" MD node corresponding to the vnet device.
> The virtual switch is expected to enforce that size for packets that go through
> it. Ideally we want a Guest OS to honor that MTU setting as well, which is probably
> not the case here. LDoms manager doesn't allow setting more than 16K today,
> I guess this code is ignoring this for Guest to Guest communication.

Yes, this is negotiated per LDC connection, and it uses the switch size when using
the switch port, but can use a full 64K linux-linux. Anything involving Solaris will
be limited to 16000, and any connections to Legacy linux will be limited to 1500 bytes.

If the port for a particular destination changes and the new port has a smaller MTU,
the packets will trigger an ICMP PMTUD notification and any active connections will
continue to work at the smaller MTU, by PMTUD design.

								+-DLS
