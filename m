From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] net: Add etun driver
Date: Tue, 10 Apr 2007 12:46:58 +0200
Message-ID: <461B6B22.3090009@trash.net>
References: <m1ps6g5229.fsf@ebiederm.dsl.xmission.com>	 <1176136628.8459.34.camel@johannes.berg> <461A70A5.8060607@trash.net>	 <20070409.114402.45491411.davem@davemloft.net>	 <m1mz1h1guo.fsf@ebiederm.dsl.xmission.com>  <461A9DF1.8080904@trash.net>	 <1176150557.8459.47.camel@johannes.berg>  <461AD517.2000906@trash.net>	 <1176184028.8459.58.camel@johannes.berg>  <461B4242.1040602@trash.net>	 <1176196734.8459.74.camel@johannes.berg>  <461B5E42.2030900@trash.net> <1176200879.8459.77.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	dim@openvz.org, netdev@vger.kernel.org, jgarzik@pobox.com,
	containers@lists.osdl.org, kuznet@ms2.inr.ac.ru,
	shemminger@linux-foundation.org, greearb@candelatech.com
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:57253 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753358AbXDJKrc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Apr 2007 06:47:32 -0400
In-Reply-To: <1176200879.8459.77.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Johannes Berg wrote:
> On Tue, 2007-04-10 at 11:52 +0200, Patrick McHardy wrote:
> 
> 
>>Without having thought much about it yet, roughly like this:
>>
>>- driver receives RTM_NEWLINK message (under rtnl)
>>- driver allocates new device
>>- driver initializes device based on content of RTM_NEWLINK message
>>- driver returns
> 
> 
> Sounds good to me, but where's the advantage over something that isn't
> generic if RTM_NEWLINK contains totally different things depending on
> the subsystem like wireless where it'd have to contain the hardware
> identifier?


Not totally different, so far I think we should use the same attributes
as for RTM_SETLINK messages and include the device-specific stuff in
IFLA_PROTINFO, which is symetric to what the kernel sends in RTM_NETLINK
messages (see br_netlink.c for an example). The easiest case would be an
empty IFLA_PROTINFO attribute, which would simply create a device
without any configuration.

The main advantage that we don't get more weird sysfs/proc/ioctl based
interfaces and use the same interface that is used for all other network
configuration, which f.e. will allow to add support for all software
devices to iproute without much effort, so you don't need 30 different
tools for configuring the different software device types anymore.
Additionally we get atomic setup/dumps and extensibility.

