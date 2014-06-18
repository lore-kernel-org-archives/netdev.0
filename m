From: Ben Greear <greearb@candelatech.com>
Subject: Re: How is IPv6 dhcp supposed to work?
Date: Wed, 18 Jun 2014 07:49:38 -0700
Message-ID: <53A1A702.1020300@candelatech.com>
References: <53A0B617.6070600@candelatech.com>  <1403044471.16272.20.camel@dcbw.local> <53A0CC31.6090707@candelatech.com>  <87ha3isdu6.fsf@nemi.mork.no> <1403098990.2266.13.camel@dcbw.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: =?UTF-8?B?QmrDuHJuIE1vcms=?= <bjorn@mork.no>,
	netdev <netdev@vger.kernel.org>
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.candelatech.com ([208.74.158.173]:53286 "EHLO
	mail2.candelatech.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750936AbaFROtj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jun 2014 10:49:39 -0400
In-Reply-To: <1403098990.2266.13.camel@dcbw.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After more printk debugging, it seems it is failing to accept the RA due to
ipv6_chk_addr failing in the ndisc_router_discovery method.

This is probably because one interface on my system is running radvd
(on one side of a veth pair), and the peer veth is supposed to be
accepting the ra.

The chk_addr is checking if the source addr for the RA is not found locally, as far
as I can tell, but in my case, it is local, and it still should be accepted.

My case is a bit special (I'm doing virtual network type things), but
maybe there is a more useful reason to allow this restriction to be
relaxed with yet another sysctl?

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
