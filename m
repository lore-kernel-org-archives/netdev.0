From: Ben Greear <greearb@candelatech.com>
Subject: Re: [RFC NET 00/02]: Secondary unicast address support
Date: Fri, 22 Jun 2007 05:08:14 -0700
Message-ID: <467BBBAE.40901@candelatech.com>
References: <20070620180017.6685.70611.sendpatchset@localhost.localdomain>	<m13b0lf7mr.fsf@ebiederm.dsl.xmission.com>	<467ACDE1.7070907@trash.net>	<m1sl8ldp6u.fsf@ebiederm.dsl.xmission.com>	<467B1311.6090001@trash.net> <467B423C.80504@candelatech.com> <m1bqf8ehku.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	shemminger@linux-foundation.org, davem@davemloft.net,
	jeff@garzik.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:46851 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752004AbXFVMN3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Jun 2007 08:13:29 -0400
In-Reply-To: <m1bqf8ehku.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric W. Biederman wrote:
> Ben Greear <greearb@candelatech.com> writes:
> 
>> Patrick McHardy wrote:
>>> Eric W. Biederman wrote:
>>>> For the macvlan code do we need to do anything special if we transmit
>>>> to a mac we would normally receive?  Another unicast mac of the same
>>>> nic for example.
>>> That doesn't happen under normal circumstances. I don't believe
>>> it would work.
>> Assuming you mean you want to send between two mac-vlans on the same physical
>> nic...
>>
>> This can work if your mac-vlans are on different subnets and you are
>> routing between them (and if you have my send-to-self patch or have
>> another way to let a system send packets to itself).
> 
> Ok.  I didn't know if you could trigger this case without without
> having then endpoints in separate namespaces.  I was suspecting
> the routing code would realize what we were doing realize the
> route is local and route through lo.

The routing code will short-circuit by default.  It takes quite
a bit of effort to make them _not_ short circuit..that is what I
was talking about.  Mac-vlans will be just like any
other ethernet nics as far as routing goes.

> 
>> A normal ethernet switch will NOT turn a packet around on the same
>> interface it was received, so that is why you must have them on different
>> subnets and have a router in between.
> 
> Yes.  That is essentially the configuration I was wondering about.
> 
>> For sending directly to yourself, something like the 'veth' driver
>> is probably more useful.
> 
> True.  And I think it has a place.  However the common case with
> the tunnel devices is to just hook them all up to an ethernet
> bridge as well as a real ethernet device.
> 
> The far ends of the ethernet tunnels are dropped into different namespaces.
> 
> Which gets a very similar effect to the mac vlan code.
> 
> I'm just wondering if I can not setup an ethernet tunnel device
> when my primary purpose is to talk to the outside world, but occasionally
> want a little in the box traffic.

mac-vlans should work on veth devices just fine, and the veths will also
short-circuit route (at least if they are in the same namespace).

I'm not sure I understand what you are trying to do..but in general
both veth and mac-vlans should act like ethernet nics..so if you can
find some way that does _not_ hold, please let us know.

Thanks,
Ben


> 
> Eric
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

