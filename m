From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] tun: change speed from 10M to dynamically
 configured
Date: Fri, 20 Feb 2015 15:07:49 -0500 (EST)
Message-ID: <20150220.150749.2049007912029090161.davem@davemloft.net>
References: <20150216120345.4dfd9950@uryu.home.lan>
	<20150219.154041.184372158520813993.davem@davemloft.net>
	<20150220023500.GK580@gospo.home.greyhouse.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, Yanjun.Zhu@windriver.com,
	romieu@fr.zoreil.com, netdev@vger.kernel.org, mst@redhat.com,
	jasowang@redhat.com, viro@zeniv.linux.org.uk,
	sergei.shtylyov@cogentembedded.com, jonathon.reinhart@gmail.com
To: gospo@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45731 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752548AbbBTUHw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2015 15:07:52 -0500
In-Reply-To: <20150220023500.GK580@gospo.home.greyhouse.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Gospodarek <gospo@cumulusnetworks.com>
Date: Thu, 19 Feb 2015 21:35:00 -0500

> On Thu, Feb 19, 2015 at 03:40:41PM -0500, David Miller wrote:
>> I see three realistic options:
>> 
>> 1) Create a link state indication which means "I am a software device,
>>    so I don't really have a link state in the traditional sense"
>> 
>> 2) Don't implement the link set/get operations at all on software
>>    devices.
>> 
>>    People can use ETHTOOL_GLINK to see if the thing is "up"
>> 
>> 3) Propagate the ultimate physical transport parameters into what
>>    the software device advertises.
>> 
>> It's important to carefully pick one of these, and consistently apply
>> it to all of our software devices.
>> 
>> I don't want TUN doing one thing, ipv4 tunnels doing another, etc.
> 
> I would prefer option #3 as it relates to the ability to transport
> offload statistics and parameters to software devices.  This could be
> useful for hardware with some form of offload vxlan/gre/etc that may be
> backed by hardare statistics (a callback to the upper device's ndo op
> could be made by the native hardware driver) or any other device without
> a proper in-kernel driver like a userspace user of tuntap that might be
> backed by something like OpenVPN.
> 
> That might help provide some more detailed, ethtool-like statistics in
> the format that is more easily readable by common monitoring tools
> without the need to have those applications look at anything except an
> ethtool/kernel interface.

netdev_feature_t like propagation is tricky because offloading
depends upon whether the device can do the offload "even in the
presence of encapsulation X".  So I don't see it as useful for
that.

But for things that are largely advisory types of information like
"physical link state", it works in a much more straightforward manner.

Link duplex and speed being wrong on a software device doesn't stop
communication, but incorrect hw offload feature flags might.
