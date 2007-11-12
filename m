From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/1][NETNS][IPV6] protect addrconf from loopback
 registration
Date: Mon, 12 Nov 2007 14:24:55 -0800 (PST)
Message-ID: <20071112.142455.73541417.davem@davemloft.net>
References: <473879C3.5020301@sw.ru>
	<47387B31.20805@fr.ibm.com>
	<473883FF.5010505@sw.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dlezcano@fr.ibm.com, netdev@vger.kernel.org, xemul@openvz.org,
	ebiederm@xmission.com, containers@lists.osdl.org,
	yoshfuji@linux-ipv6.org, benjamin.thery@bull.net
To: den@sw.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40451
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754088AbXKLWY4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Nov 2007 17:24:56 -0500
In-Reply-To: <473883FF.5010505@sw.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Denis V. Lunev" <den@sw.ru>
Date: Mon, 12 Nov 2007 19:49:03 +0300

> Unregister for a loopback in !init_net is a _valid_ operation and should
> be clean, i.e. without kludges in the path. This is the only way to
> check the ref-counting.

For ipv6 the stack really wants to pin down the loopback
device because we need a valid inet6_dev object to reference
at all times in order to simplify the per-device SNMP
statistic bumping.

When a non-loopback device goes down, we point any existing
references to that device's idev to the loopback one instead.

I really consider taking down the loopback device to be
an invalid operation at least how things are implemented
currently.

There was a suggestion to have a "dummy" device that takes the
place of "point dangling idev refs to loopback's one".  But
some people get upset when statistical events get lost, and
rightly so.  Such a dummy device would either need to be
invisible to the user, or show up and be utterly confusing.

