From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] net/core: Save the port number a netdevice uses
Date: Wed, 02 Jun 2010 17:42:29 +0100
Message-ID: <1275496949.2115.18.camel@achroite.uk.solarflarecom.com>
References: <20100526084523.GA28748@mtldesk030.lab.mtl.com>
	 <20100526.015526.102555441.davem@davemloft.net>
	 <20100526090850.GB28748@mtldesk030.lab.mtl.com>
	 <20100526.021635.179940939.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Eli Cohen <eli@dev.mellanox.co.il>,
	netdev <netdev@vger.kernel.org>, linux-rdma@vger.kernel.org,
	Roland Dreier <rdreier@cisco.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.co.il>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:46572 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752875Ab0FBQmd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jun 2010 12:42:33 -0400
In-Reply-To: <20100526.021635.179940939.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-05-26 at 02:16 -0700, David Miller wrote:
> From: Eli Cohen <eli@dev.mellanox.co.il>
> Date: Wed, 26 May 2010 12:08:52 +0300
> 
> > So if I understand you correctly, you think that I should not bother
> > to set a default value of 1. Each driver that cares about the value
> > of this field, will set it however they want.
> 
> I actually mean that the value "0" should mean the first port,
> the value "1" should mean the second port, etc.

There's a compatibility problem here though: when user-space looks at
this number it can't tell whether "0" really means the first port or
that the driver isn't setting dev_id.  In order to tell that it would
have to check the driver or kernel version too, and this is really nasty
(what if the driver was backported?).  So I think that 1-based numbering
for drivers that previously didn't set dev_id.

Why does this matter?  I'm maintaining the firmware update program for
Solarflare NICs under Linux.  Some of the firmware it updates is
per-port and some of it is per-board.  It needs to be able to tell which
net and PCI devices are associated with the same board.  At the moment
it works on the basis of PCI addresses, but this is unreliable in the
presence of virtualisation.  It would be better to use board serial
number and the port identifier that I just changed the driver to use,
but since there are existing driver versions always leave dev_id = 0, I
it needs to be able to tell whether dev_id is meaningful.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

