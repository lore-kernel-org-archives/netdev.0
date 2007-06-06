From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC RTNETLINK 00/09]: Netlink link creation API
Date: Wed, 06 Jun 2007 18:25:05 +0200
Message-ID: <4666DFE1.4040200@trash.net>
References: <20070605141250.15650.47178.sendpatchset@localhost.localdomain>	<m1tztlvrsp.fsf@ebiederm.dsl.xmission.com>	<46669FA0.3030405@trash.net>	<m1d509umtp.fsf@ebiederm.dsl.xmission.com>	<4666D426.2070606@trash.net> <m14plluklr.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, socketcan@hartkopp.net, hadi@cyberus.ca,
	xemul@sw.ru, tgraf@suug.ch
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:57380 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751648AbXFFQZf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jun 2007 12:25:35 -0400
In-Reply-To: <m14plluklr.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric W. Biederman wrote:
> Patrick McHardy <kaber@trash.net> writes:
> 
> 
>>>I still think adding a IFLA_PARTNER or a custom attribute is cleaner
>>>in this case.  Slight semantic mismatches are the worst design bugs
>>>to correct.
>>
>>
>>Indeed, IFLA_PARTNER sounds like a better idea. I just suggested to
>>Pavel to create only a single device per newlink operation and binding
>>them later, what do you think about that?
> 
> 
> I don't think it solves much because we still need a way to report the
> partner device.

I was thinking of something like this:

ip link add veth0 type veth
ip link add veth1 partner veth0 type veth

ip would resolve veth0 to an ifindex and set IFLA_PARTNER. But Alexey
just raised a few good points, so this might not work.

> On the actual using side I think it makes the core of the driver much
> more difficult to get right.  
> 
> Basically if we can't count on having a partner device we have to
> add NULL pointer checks and locking to the packet dispatch which
> is otherwise unnecessary.


All you'd need to do is keep the queue stopped until the device
is bound. No changes to rx or tx path neccessary.
