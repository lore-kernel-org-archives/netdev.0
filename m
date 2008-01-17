From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH 3/4] bonding: Fix work rearming
Date: Thu, 17 Jan 2008 12:18:22 +0100
Message-ID: <20080117111822.GB1710@ff.dom.local>
References: <20080115090532.GB1696@ff.dom.local> <478D77D7.60703@miraclelinux.com> <20080116133646.GE2307@ff.dom.local> <478EE7FC.4040301@miraclelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Makito SHIOKAWA <mshiokawa@miraclelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.189]:55305 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751180AbYAQLMA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2008 06:12:00 -0500
Received: by fk-out-0910.google.com with SMTP id z23so373372fkz.5
        for <netdev@vger.kernel.org>; Thu, 17 Jan 2008 03:11:56 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <478EE7FC.4040301@miraclelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 17, 2008 at 02:30:36PM +0900, Makito SHIOKAWA wrote:
>> But, since during this change from sysfs cancel_delayed_work_sync()
>> could be probably used, and it's rather efficient with killing
>> rearming works, it seems this check could be unnecessary yet.
> What going to be cancelled in bonding_store_miimon() when setting miimon to 
> 0 is arp monitor, not mii monitor. So, this check will be needed to stop 
> rearming mii monitor when value 0 is set to miimon.

Hmm... I'm not sure I understand your point, but it seems both
bonding_store_arp_interval() and bonding_store_miimon() where this
field could be changed, currently use cancel_delayed_work() with
flush_workqueue(), so I presume, there is no rtnl_lock() nor
write_lock(&bond->lock) held, so cancel_delayed_work_sync() could
be used, which doesn't require this additional check.

...Unless you mean that despite miimon value is changed there,
mii_work for some reason can't be cancelled at the same time?

Of course, if there is such a reason for doing this check each time
a work runs instead of controlling where the value changes, then OK!

Regards,
Jarek P.
