From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] net: Add etun driver
Date: Mon, 09 Apr 2007 20:45:51 +0200
Message-ID: <461A89DF.1030307@trash.net>
References: <m1abxl5j4s.fsf@ebiederm.dsl.xmission.com>	 <20070406133420.2f098bc6@localhost>	 <m1ps6g5229.fsf@ebiederm.dsl.xmission.com> <1176136628.8459.34.camel@johannes.berg> <461A70A5.8060607@trash.net> <461A829C.7050703@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Johannes Berg <johannes@sipsolutions.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Jeff Garzik <jgarzik@pobox.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	Dmitry Mishin <dim@openvz.org>,
	Linux Containers <containers@lists.osdl.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:42137 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753401AbXDISqJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Apr 2007 14:46:09 -0400
In-Reply-To: <461A829C.7050703@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ben Greear wrote:
> Patrick McHardy wrote:
> 
>> It would be nice if someone would finally come up with a generic
>> interface based on netlink (RTM_NEWLINK) instead of adding yet
>> another couple of homegrown interfaces.
> 
> 
> My preference is for ioctls, procfs, or similar that does not
> require extra libraries.  Ethtool is an ioctl based approach,
> so that could potentially be used, though I'm not sure if
> that's the right place to put it...


Extra libraries is one of the least important points in my opinion,
I also guess pretty much anyone using a software device already has
iproute installed, which could easily support all of them.

The more important things to consider are in my opinion extendability
and atomicity of changes and dumps:

- ioctls: atomicity, not easily extendable
- sysfs: no atomicity, easily extendable
- procfs: if atomicity not easily extendable, but can of course also
  be used similar to sysfs

Only netlink offers both in an easy to use fashion and is already used
for the main parts of network configuration anyway.
