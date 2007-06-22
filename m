From: Ben Greear <greearb@candelatech.com>
Subject: Re: [RFC NET 00/02]: Secondary unicast address support
Date: Thu, 21 Jun 2007 20:30:04 -0700
Message-ID: <467B423C.80504@candelatech.com>
References: <20070620180017.6685.70611.sendpatchset@localhost.localdomain>	<m13b0lf7mr.fsf@ebiederm.dsl.xmission.com>	<467ACDE1.7070907@trash.net> <m1sl8ldp6u.fsf@ebiederm.dsl.xmission.com> <467B1311.6090001@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	netdev@vger.kernel.org, shemminger@linux-foundation.org,
	davem@davemloft.net, jeff@garzik.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:33323 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751049AbXFVDaW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Jun 2007 23:30:22 -0400
In-Reply-To: <467B1311.6090001@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> Eric W. Biederman wrote:

>> For the macvlan code do we need to do anything special if we transmit
>> to a mac we would normally receive?  Another unicast mac of the same
>> nic for example.
> 
> That doesn't happen under normal circumstances. I don't believe
> it would work.

Assuming you mean you want to send between two mac-vlans on the same physical
nic...

This can work if your mac-vlans are on different subnets and you are
routing between them (and if you have my send-to-self patch or have
another way to let a system send packets to itself).

A normal ethernet switch will NOT turn a packet around on the same
interface it was received, so that is why you must have them on different
subnets and have a router in between.

For sending directly to yourself, something like the 'veth' driver
is probably more useful.

> 
>> For the macvlan hash you just use an upper byte.  Is that just a
>> simple starting place, or do we not need a more complex hash.
>>   
> 
> It comes from the original code, I think it should be good enough.

Ahhh, I knew my hash was lame for some reason!

Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

