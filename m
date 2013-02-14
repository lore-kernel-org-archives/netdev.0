From: Chris Friesen <chris.friesen@genband.com>
Subject: Re: how to handle bonding failover when using a bridge over the bond?
Date: Thu, 14 Feb 2013 13:29:00 -0600
Message-ID: <511D3AFC.10504@genband.com>
References: <511ACE16.3080906@genband.com> <32261.1360713746@death.nxdomain> <511ADEBB.1000701@genband.com> <kfi5k6$1mq$1@ger.gmane.org> <511D141B.602@genband.com> <23692.1360864993@death.nxdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og118.obsmtp.com ([64.18.2.8]:60005 "EHLO
	exprod7og118.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758702Ab3BNTaF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Feb 2013 14:30:05 -0500
In-Reply-To: <23692.1360864993@death.nxdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/14/2013 12:03 PM, Jay Vosburgh wrote:
> Chris Friesen<chris.friesen@genband.com>  wrote:

>> The problem is that L2 switch "B" still thinks that all the virtual
>> machines are accessible via L2 switch "A".  Thus any incoming packets
>> destined for a virtual machine will get dropped.
>
> 	I'm trying to track down the system I tested previously to see
> exactly how it is set up and why it works when yours does not.  It's
> possible that it doesn't work, and the testing we did simply missed this
> case.

After thinking about this for a while, it doesn't seem like a natural 
thing for either the bond or the bridge to care about--though if someone 
wanted to fix it generically that would be great.

It might be worth considering sending out a bonding-specific netlink 
message when a bond fails over, giving the name of the bond as well as 
the newly active slave device.  This would allow for an efficient 
userspace daemon to issue gratuitous arps for all the VM MAC addresses.

It almost seems like the most elegant way to deal with this would be to 
forgo the bond completely and just add both links into the bridge, then 
run STP to make sure there are no loops.  That way link pulls get 
handled immediately and STP will update the other L2 switches 
appropriately.  Unfortunately this doesn't seem to be an option for us 
since some apparently customers frown on a server participating in STP. 
(Not sure why, we're already dealing with much more complicated 
protocols...)

Chris
