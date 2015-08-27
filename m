From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [RFC PATCH net-next 0/2] Add new switchdev device class
Date: Thu, 27 Aug 2015 09:51:10 +0200
Message-ID: <20150827075110.GM2228@nanopsycho.orion>
References: <1440659806-56582-1-git-send-email-sfeldma@gmail.com>
 <20150827072722.GJ2228@nanopsycho.orion>
 <55DEBFBA.9030601@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: sfeldma@gmail.com, netdev@vger.kernel.org, davem@davemloft.net,
	f.fainelli@gmail.com, roopa@cumulusnetworks.com
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:33706 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751341AbbH0HvO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Aug 2015 03:51:14 -0400
Received: by wijn1 with SMTP id n1so46711650wij.0
        for <netdev@vger.kernel.org>; Thu, 27 Aug 2015 00:51:13 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <55DEBFBA.9030601@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Aug 27, 2015 at 09:43:54AM CEST, john.fastabend@gmail.com wrote:
>On 15-08-27 12:27 AM, Jiri Pirko wrote:
>> Thu, Aug 27, 2015 at 09:16:44AM CEST, sfeldma@gmail.com wrote:
>>> From: Scott Feldman <sfeldma@gmail.com>
>>>
>>> In the switchdev model, we use netdevs to represent switchdev ports, but we
>>> have no representation for the switch itself.  So, introduce a new switchdev
>>> device class so we can define semantics and programming interfaces for the
>>> switch itself.  Switchdev device class isn't tied to any particular bus.
>>>
>>> This patch set is just the skeleton to get us started.  It adds the sysfs
>>> object registration for the new class and defines a class-level attr "foo".
>>> With the new class, we could hook PM functions, for example, to handle power
>>> transitions at the switch level.  I registered rocker and get:
>>>
>>>   $ ls /sys/class/switchdev/5254001235010000/
>>>   foo  power  subsystem  uevent
>> 
>> No, please avoid adding anything to sysfs. If we need to add anything,
>> lets make is accesible using Netlink only.
>> 
>> 
>>>
>>> So what next?  I'd rather not build APIs around sysfs, so we need a netlink API
>>> we can build on top of this.  It's not really rtnl.  Maybe genl would work?
>>> What ever it is, we'd need to teach iproute2 about a new 'switch' command.
>>>
>>> Netlink API would allow us to represent switch-wide objects such as registers,
>>> tables, stats, firmware, and maybe even control.  I think with with netlink
>>> TLVs, we can create a framework for these objects but still allow the switch
>>> driver provide switch-specific info.  For example, a table object:
>>>
>>> [TABLES]
>>> 	[TABLE]
>>> 		[FIELDS]
>>> 			[FIELD]
>>> 				[ID, TYPE]
>>> 		[DATA]
>>> 			[ID, VALUE]
>> 
>> Alert! I feel that someone would like to abuse this iface for writing
>> configuration through. This should be read-only by design. I also think
>> that this should not be something switch-specific. I believe that NIC
>> drivers would benefit from this iface as well when they want to expose
>> something. I think we should use genl for this.
>> 
>
>One place where read-only may not make sense is when the tables can
>be provisioned/configured. Many switches have the ability to be
>configured with "profiles". For a simple example some hardware use a
>single table that can be divided into an IPv4 and an IPv6 section.

Okay. That should be configured via separate configuration Netlink
interface - ConfNetlink. I already spoke with Dave about need for
that one: Netlink based, use PCI-addr (other addr) as a handle,
well-defined config objects. The need to this interface is bigger and bigger.

I can cook-up some RFC patch so you see what I'm talking about.
