From: David Miller <davem@davemloft.net>
Subject: Re: [RFC V2 PATCH] rtnetlink: Fix problem with buffer allocation
Date: Tue, 14 Feb 2012 16:31:38 -0500 (EST)
Message-ID: <20120214.163138.447136245539138324.davem@davemloft.net>
References: <20120212191342.1458.70498.stgit@gitlad.jf.intel.com>
	<1329253993.2443.30.camel@bwh-desktop>
	<C5551D9AAB213A418B7FD5E4A6F30A0702F8C728@ORSMSX106.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org
To: gregory.v.rose@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:49524 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760610Ab2BNVbl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Feb 2012 16:31:41 -0500
In-Reply-To: <C5551D9AAB213A418B7FD5E4A6F30A0702F8C728@ORSMSX106.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Rose, Gregory V" <gregory.v.rose@intel.com>
Date: Tue, 14 Feb 2012 21:27:59 +0000

> That's a real sticky problem.  When the dump request comes in we
> don't know how big the required buffer might actually get.  That's
> why we used to have the min_ifinfo_dump_size.  However there were
> problems with that also so Dave asked me to get rid of it.  The only
> thing I could come up with just allocating a really big buffer.  If
> someone could point out to me how to get a maximum ifinfo dump size
> before rtnl_dump_ifinfo starts filtering through the matching
> interfaces then that would really help.  But at the point the dump
> request comes in we don't know beforehand how to calculate the info
> dump size because if_nlmsg_size() requires a pointer to a netdevice.

Two quick ideas:

1) Have a first pass which iterates over the devices and calculates
   the maximum of all if_nlmsg_size() calculations over those devices
   then uses that for the dump buffer allocation size.

2) Replace min_ifinfo_dump_size() with an array of sizes, one for
   each combination of extended features.  The only concern with this
   one is that whilst it's practical to do this now with only 1 or
   a few feature bits, in the future it may be a lot less practical.
