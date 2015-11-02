From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH v3 net] i40e: Look up MAC address in Open Firmware or
 IDPROM
Date: Mon, 2 Nov 2015 14:57:07 -0500
Message-ID: <20151102195707.GC15009@oracle.com>
References: <FC41C24E35F18A40888AACA1A36F3E418AFACA14@fmsmsx115.amr.corp.intel.com>
 <20151030183645.GD32759@oracle.com>
 <FC41C24E35F18A40888AACA1A36F3E418AFACA8F@fmsmsx115.amr.corp.intel.com>
 <20151030192437.GE32759@oracle.com>
 <FC41C24E35F18A40888AACA1A36F3E418AFACC2E@fmsmsx115.amr.corp.intel.com>
 <20151030231301.GA14974@oracle.com>
 <20151101162407.GA26373@oracle.com>
 <FC41C24E35F18A40888AACA1A36F3E418AFAD1C9@fmsmsx115.amr.corp.intel.com>
 <20151102000701.GD9552@oracle.com>
 <FC41C24E35F18A40888AACA1A36F3E418AFAD398@fmsmsx115.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"andy.shevchenko@gmail.com" <andy.shevchenko@gmail.com>,
	sowmini.varadhan@oracle.com
To: "Nelson, Shannon" <shannon.nelson@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:23824 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751684AbbKBT5L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2015 14:57:11 -0500
Content-Disposition: inline
In-Reply-To: <FC41C24E35F18A40888AACA1A36F3E418AFAD398@fmsmsx115.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (11/02/15 17:26), Nelson, Shannon wrote:
> > I assume you mean .1q 
> 
> Yes, this is what I had in mind.

I dont think we're quite there yet, even without vlans.

If I turn on/off tcpdump, there's something about the way that the link
is bounced that leaves the device down while tcpdump is running. Then
after I exit tcpdump, it bounces things a few more times again, packets
flow for a brief interval, and then there's silence.

Seems like there's is a workq that results in
i40e_service_task->i40e_sync_vsi_filters that periodically resets things.

Doing 'ip link set eth0 promisc on' keeps things nice and steady.

How is this all supposed to work if I change the macaddr from /sbin/ip 
using i40e_set_mac() and then jiggle the promisc (either just the flag,
or with tcpdump)? (I cant tell because I dont have an x86 machine with 
i40e handy)

To frame the question differently, where all should I be invoking
the new i40e_macaddr_init() function from? 

--Sowmini
