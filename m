From: Ben Greear <greearb@candelatech.com>
Subject: Re: Is it valid to add a macvlan virtual interface to a bridge? If
 so, there seems to be a bug with it.
Date: Fri, 05 Dec 2008 09:43:25 -0800
Message-ID: <4939683D.40406@candelatech.com>
References: <20081204203352.9740c60e.ipng@69706e6720323030352d30312d31340a.nosense.org> <4937D494.8080202@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Mark Smith <ipng@69706e6720323030352d30312d31340a.nosense.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:46085 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752089AbYLERnd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Dec 2008 12:43:33 -0500
In-Reply-To: <4937D494.8080202@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy wrote:

>> Should what I'm doing be working or possible? If not, could something
>> be added to the kernel to prevent macvlan interfaces being added to
>> bridge instances, to stop other people spending time trying to do what
>> I've tried to do?
> 
> Unfortunately one of both combinations will not work, no matter
> what we do. The bridge code could issue a warning when adding
> a bridge on top of a macvlan device, but there's no clean indication
> that something is a macvlan device besides dev->rtnl_link_ops->kind
> being "macvlan".

A mac-vlan can't really be PROMISC either since it only receives
BCAST frames and packets destined for it's own MAC, so I can't see
how it could work in a bridge....

user-space brctl could check for the driver string returned by
ethtool API to check if no one wants any additional cruft in
the kernel...


You might try using a pair of VETH interfaces to bridge between
your host and virtual host.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

