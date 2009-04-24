From: Ben Greear <greearb@candelatech.com>
Subject: Re: vlan: update vlan carrier state for admin up/down
Date: Fri, 24 Apr 2009 09:39:11 -0700
Message-ID: <49F1EB2F.1050505@candelatech.com>
References: <49F1DE6F.1030606@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:51201 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753846AbZDXQjP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Apr 2009 12:39:15 -0400
In-Reply-To: <49F1DE6F.1030606@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Suppose that someone has eth0, eth0.2 and eth0.5 admin UP.

Then, sets eth0.5 admin DOWN.

Later they set eth0 down and up for some reason.

Would eth0.5 now go admin UP?

If so, I think that is not a good idea and could possibly be considered
a security issue.  I think instead there should be a new flag for VLANs
that is 'preferred-admin-state'.  To be UP, both the underlying device
and the preferred state must be UP.  That should allow bouncing eth0
w/out affecting the eventual admin state of the VLANs on eth0 in
the example above.

For what it's worth, it seems that other virtual devices, such as VIFS
on a wifi radio, might need the same sort of behaviour.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

