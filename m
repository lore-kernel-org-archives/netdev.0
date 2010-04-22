From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 1/2] add iovnl netlink support
Date: Thu, 22 Apr 2010 03:56:15 -0700 (PDT)
Message-ID: <20100422.035615.176728799.davem@davemloft.net>
References: <20100419191807.10423.84600.stgit@savbu-pc100.cisco.com>
	<20100421.235236.69366636.davem@davemloft.net>
	<201004221253.11290.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: scofeldm@cisco.com, netdev@vger.kernel.org, chrisw@redhat.com
To: arnd@arndb.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58799
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754197Ab0DVK4K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Apr 2010 06:56:10 -0400
In-Reply-To: <201004221253.11290.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnd Bergmann <arnd@arndb.de>
Date: Thu, 22 Apr 2010 12:53:11 +0200

> On Thursday 22 April 2010, David Miller wrote:
>> From: Scott Feldman <scofeldm@cisco.com>
>> Date: Mon, 19 Apr 2010 12:18:07 -0700
>> 
>> > +     if (tb[IOV_ATTR_VF_IFNAME])
>> > +             vf_dev = dev_get_by_name(&init_net,
>> > +                     nla_data(tb[IOV_ATTR_VF_IFNAME]));
>> 
>> It's probably best to check this for NULL and notify
>> the user with an error in that case (don't forget to
>> put 'dev' in that error path :-)
> 
> Since you brought up that hunk: shouldn't the namespace better
> be current->nsproxy->net_ns instead of init_ns? If the sender
> is confined in a separate network namespace, I would expect
> that it should be able to modify devices in its own namespace
> but none that are in the root namespace.

Yes, the namespace needs to be handled better.

But reading other parts of the discussion it seems that
IOV_ATTR_VF_IFNAME and some other bits will likely be
removed in the initial implementation of this stuff.
