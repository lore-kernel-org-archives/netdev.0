From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [patch 1/1][NETNS][IPV6] protect addrconf from loopback registration
Date: Tue, 13 Nov 2007 05:59:38 -0700
Message-ID: <m1r6iu2tdx.fsf@ebiederm.dsl.xmission.com>
References: <473879C3.5020301@sw.ru> <47387B31.20805@fr.ibm.com>
	<473883FF.5010505@sw.ru>
	<20071112.142455.73541417.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: den@sw.ru, dlezcano@fr.ibm.com, netdev@vger.kernel.org,
	xemul@openvz.org, containers@lists.osdl.org,
	yoshfuji@linux-ipv6.org, benjamin.thery@bull.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:46647 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752023AbXKMNCh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2007 08:02:37 -0500
In-Reply-To: <20071112.142455.73541417.davem@davemloft.net> (David Miller's
	message of "Mon, 12 Nov 2007 14:24:55 -0800 (PST)")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> writes:

Well this is a weird way to get to this part of the conversation.

> From: "Denis V. Lunev" <den@sw.ru>
> Date: Mon, 12 Nov 2007 19:49:03 +0300
>
>> Unregister for a loopback in !init_net is a _valid_ operation and should
>> be clean, i.e. without kludges in the path. This is the only way to
>> check the ref-counting.
>
> For ipv6 the stack really wants to pin down the loopback
> device because we need a valid inet6_dev object to reference
> at all times in order to simplify the per-device SNMP
> statistic bumping.
>
> When a non-loopback device goes down, we point any existing
> references to that device's idev to the loopback one instead.
>
> I really consider taking down the loopback device to be
> an invalid operation at least how things are implemented
> currently.

In a secondary network namespace the current implementation
registers the loopback device before all other network devices
in a network namespace and it unregisters the loopback device
after all other network devices.

So we don't endanger the current scheme of pointing any existing
reference to the loopback device.  In fact the current ipv6 addrconf_cleanup
largely does the same thing.

Unregistering the loopback device is definitely a case where we need
to tread very carefully.

Bug we absolutely need to do all of our cleanup for a network
namespace went it goes away and that includes removing the per network
namespace copy of the loopback device.

Eric
