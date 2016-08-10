From: =?iso-8859-1?Q?J=F6rn?= Engel <joern@purestorage.com>
Subject: Re: [PATCH] bonding: Allow tun-interfaces as slaves
Date: Wed, 10 Aug 2016 14:26:49 -0700
Message-ID: <20160810212649.GD5019@cork>
References: <CAD=hENd01nGdvB9GseG+CrWn3f0PXyGgwOmf=+MVAfuW7Hv9Nw@mail.gmail.com>
 <57A9DA8D.3010407@huawei.com>
 <20160809180830.GM22974@cork>
 <20160809.120636.2039586307820412288.davem@davemloft.net>
 <20160809211058.GP22974@cork>
 <20075.1470786664@famine>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: David Miller <davem@davemloft.net>, dingtianhong@huawei.com,
	zyjzyj2000@gmail.com, andy@greyhouse.net, netdev@vger.kernel.org
To: Jay Vosburgh <jay.vosburgh@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:34683 "EHLO
	mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932500AbcHJV05 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Aug 2016 17:26:57 -0400
Received: by mail-pf0-f182.google.com with SMTP id p64so19538611pfb.1
        for <netdev@vger.kernel.org>; Wed, 10 Aug 2016 14:26:57 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20075.1470786664@famine>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 09, 2016 at 04:51:04PM -0700, Jay Vosburgh wrote:
> 
> 	This will cause balance-rr to add the slave to the bond if any
> device's dev_set_mac_address call fails.
> 
> 	If a bond of regular Ethernet devices is connected to a static
> link aggregation (Etherchannel channel group), a set_mac failure would
> result in that slave having a different MAC address than the bond, which
> in turn would cause traffic inbound from the switch to that slave to be
> dropped (as the destination MAC would not pass the device MAC filters).
> 
> 	The failure check for the set_mac call serves a legitimate
> purpose, and I don't believe we should bypass it without making the
> bypass an option that is explicitly enabled for those special cases that
> need it.
> 
> 	E.g., something like the following (which I have not tested);
> this would also need documentation and iproute2 updates to go with it.
> This would be enabled with "fail_over_mac=keepmac".

Thank you!

Tested-by: Jörn Engel <joern@purestorage.com>

Having to set one more parameter is a bit annoying.  It would have to be
documented in a prominent place and people would still often miss it.
So I wonder if we can make the interface a little nicer.

Options:
- If there are no slaves yet and the first slave added is tun, we trust
  the users to know what they are doing.  Automatically set
  bond->params.fail_over_mac = BOND_FOM_KEEPMAC
  Maybe do a printk to inform the user in case of a mistake.
- If we get an error and the slave device is tun, do a printk giving the
  user enough information to find this parameter.

I'm leaning towards the former, but you probably know a reason why I am
wrong again.

Jörn
