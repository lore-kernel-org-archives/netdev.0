From: Patrick McHardy <kaber@trash.net>
Subject: Re: [Bugme-new]  [Bug 9719] New: when a system is configured as a
 bridge, and at the same time configured to have multipath weighted route,
 with one leg goes thru NAT and another without NAT, the nat path will intermittently
 get packets leaking out using internal IP without being SNAT-ted
Date: Thu, 10 Jan 2008 16:41:28 +0100
Message-ID: <47863CA8.1010301@trash.net>
References: <bug-9719-10286@http.bugzilla.kernel.org/> <20080109152813.83fb8168.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org
To: mingching.tiew@redtone.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:57500 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755819AbYAJPpz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jan 2008 10:45:55 -0500
In-Reply-To: <20080109152813.83fb8168.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Morton wrote:
>> Distribution: iptables 1.4.0 was used with kernel 2.6.23 and iptables 1.3.8
>> with 2.6.22.15
>> Hardware Environment: 3 interfaces, 2 interfaces bridged to form br0, and
>> another connects to internet using pppoe.
>> Software Environment: bridge, multipath routing
>> Problem Description: when a system is configured as a bridge with IP assigned
>> to br0 interface, and at the same time it is configured to have multipath
>> weighted default route, and one of the default route is NAT-ed and another of
>> the default route is not NAT-ed, then it is NAT-ed interface will occasionally
>> get packets leaking out to it with packets with private IPs.


That is most likely because the route changes over time (when the cache
is flushed) and the NAT mappings for the connection have been set up on
a different interface. The way to properly do this is to add routing
rules based on fwmark and use CONNMARK to bind a connection to one of
the interfaces after the initial multipath routing decision.
