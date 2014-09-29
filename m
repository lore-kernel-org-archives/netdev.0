From: Ben Greear <greearb@candelatech.com>
Subject: Re: IPv6 FIB related crash with MACVLANs in 3.9.11+ kernel.
Date: Mon, 29 Sep 2014 14:24:54 -0700
Message-ID: <5429CE26.6000108@candelatech.com>
References: <52EFFE20.5080500@candelatech.com> <20140203220323.GB17999@order.stressinduktion.org> <52F012FF.9030105@candelatech.com> <52F65EB4.1050306@candelatech.com> <20140208172310.GF16198@order.stressinduktion.org> <loom.20140926T001736-777@post.gmane.org> <1411906297.2400343.172598909.66223582@webmail.messagingengine.com> <loom.20140929T195637-887@post.gmane.org> <5429A886.1040809@candelatech.com> <1412017399.14757.4.camel@localhost> <5429B783.20207@candelatech.com> <CAHA+R7O_xghD4a5RD=omhnuMD72pRmKU9VMoxPUVuGcu682jBg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Hongmei Li <duckcncn@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.candelatech.com ([208.74.158.173]:53544 "EHLO
	mail2.candelatech.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751057AbaI2VYz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2014 17:24:55 -0400
In-Reply-To: <CAHA+R7O_xghD4a5RD=omhnuMD72pRmKU9VMoxPUVuGcu682jBg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/29/2014 01:39 PM, Cong Wang wrote:
> On Mon, Sep 29, 2014 at 12:48 PM, Ben Greear <greearb@candelatech.com> wrote:
>>
>> We are going to be running up to 20 concurrent scripts that
>> will be dumping routes & ips, and configuring ip addresses
>> and routes during bringup.
>>
>> I don't have a simple stand-alone way to reproduce this,
>> but at least when we reported the problem is was very easy
>> for us to reproduce with our tool.
>>
>> Maybe 20 scripts running in parallel that randomly configured and dumped routes
>> and ip addresses on random interfaces would do the trick?
>>
> 
> I think the most important question is why is this related with macvlan?
> IPv6 is L3 while macvlan pure L2, if this is a IPv6 routing bug, it should
> not be limited to macvlan.

We saw it using mac-vlans on top of ixgbe.  Probably it can be reproduced
elsewhere, but since we had a good test case, we didn't bother trying lots
of other combinations.

Just enabling some debug code caused the problem to be much harder
to reproduce, so it is probably some sort of race.  Maybe lots of mac-vlans
make it easier to hit.

> What does your IPv6 routing table look like? And how do you configure those
> macvlan interfaces?

Each interface would have it's own routing table, with at least as subnet
route.  I'm not sure we were adding a default gateway or not.

The main routing table would also have some auto-created routes
I think.

It is configured using 'ip' to add and dump routes.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
