From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: how to handle bonding failover when using a bridge over the bond?
Date: Thu, 14 Feb 2013 08:01:10 +0000 (UTC)
Message-ID: <kfi5k6$1mq$1@ger.gmane.org>
References: <511ACE16.3080906@genband.com> <32261.1360713746@death.nxdomain>
 <511ADEBB.1000701@genband.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:48605 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756181Ab3BNIBX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Feb 2013 03:01:23 -0500
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1U5tlG-00048W-0D
	for netdev@vger.kernel.org; Thu, 14 Feb 2013 09:01:42 +0100
Received: from 180.129.241.48 ([180.129.241.48])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 14 Feb 2013 09:01:41 +0100
Received: from xiyou.wangcong by 180.129.241.48 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 14 Feb 2013 09:01:41 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 13 Feb 2013 at 00:30 GMT, Chris Friesen <chris.friesen@genband.com> wrote:
> On 02/12/2013 06:02 PM, Jay Vosburgh wrote:
>> 	The bond doesn't track all of the MACs that go through it, but
>> the bridge presumably does, and could respond to the FAILOVER notifier
>> with something to notify the switch that the port assignments for the
>> various MACs have changed.
>
> That would probably make sense.  I've added the bridging folks, maybe 
> they'll have a suggestion how this sort of thing should be handled.
>

It is already handled. When BONDING_FAILOVER is triggered and the MAC has
been changed, NETDEV_CHANGEADDR is issued too, then bridge will capture
it and update its fdb:

        case NETDEV_CHANGEADDR:
                spin_lock_bh(&br->lock);
                br_fdb_changeaddr(p, dev->dev_addr);
                changed_addr = br_stp_recalculate_bridge_id(br);
                spin_unlock_bh(&br->lock);

                if (changed_addr)
                        call_netdevice_notifiers(NETDEV_CHANGEADDR, br->dev);

                break;
		
