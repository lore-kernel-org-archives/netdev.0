From: David Miller <davem@davemloft.net>
Subject: Re: depending on IPv6 symbols
Date: Tue, 06 Feb 2007 14:49:39 -0800 (PST)
Message-ID: <20070206.144939.118629871.davem@davemloft.net>
References: <20061229144702.11ff0478.kazunori@miyazawa.org>
	<20070206.142407.48395902.davem@davemloft.net>
	<adaodo6sy9o.fsf_-_@cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kazunori@miyazawa.org, miika@iki.fi, Diego.Beltrami@hiit.fi,
	herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	usagi-core@linux-ipv6.org, mst@mellanox.co.il
To: rdreier@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58181
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1030224AbXBFWuE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Feb 2007 17:50:04 -0500
In-Reply-To: <adaodo6sy9o.fsf_-_@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Roland Dreier <rdreier@cisco.com>
Date: Tue, 06 Feb 2007 14:43:15 -0800

> So I hope we can come up with a short-range plan to deal with the
> possibility of built-in code calling icmpv6_send() at least...  As you
> said, should we just convert IPV6 to a bool instead of a tristate?

Netfilter handles this by using the Kconfig dependency construct:

config FOO
	depends on (IPV6 || IPV6=n)

which essentially means:

if IPV6 is disabled:

	Allow FOO to build modular or static, but will get no ipv6
	support.

if IPV6 is "y"

	Allow FOO to be a static or modular build

if IPV6 is "m"

	Allow FOO to be a modular build only

This is the only way to make it all work out currently.
