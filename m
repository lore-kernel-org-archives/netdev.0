From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: Seeing new kernel unaligned access messages in linux-next on
 ia64
Date: Thu, 25 Mar 2010 00:17:01 +0100 (CET)
Message-ID: <alpine.LSU.2.01.1003250014400.16715@obet.zrqbmnf.qr>
References: <12c511ca1003181112t6098eeafm30e384e755a42185@mail.gmail.com> <alpine.LSU.2.01.1003192310450.10055@obet.zrqbmnf.qr> <20100324.102759.107122703.davem@davemloft.net> <alpine.LSU.2.01.1003242059230.4028@obet.zrqbmnf.qr> <m2vdcl5ocj.fsf@igel.home>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, tony.luck@intel.com,
	netdev@vger.kernel.org
To: Andreas Schwab <schwab@linux-m68k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from borg.medozas.de ([188.40.89.202]:55713 "EHLO borg.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752107Ab0CXXRD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Mar 2010 19:17:03 -0400
In-Reply-To: <m2vdcl5ocj.fsf@igel.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Wednesday 2010-03-24 23:47, Andreas Schwab wrote:
>Jan Engelhardt writes:
>
>> Using a temporary and memcpying it off would normally fix this,
>> as in the patch below. During testing however, I still get
>> unaligned messages even with the patch - and I would not know
>> what causes this.
>
>The memcpy will not fix the alignment issue because the copy operation
>is fully equivalent to a direct assignment, and the compiler can still
>take advantage of the known alignment of the types.  You have to
>explicitly tell the compiler about the reduced alignment guarantee.

You're right, I remember seeing that sort of optimization before. So I 
have changed the function's signature to read

-static void copy_rtnl_link_stats64(struct rtnl_link_stats64 *v,
-                                  const struct net_device_stats *b)
+static void copy_rtnl_link_stats64(void *v, const struct net_device_stats *b)
 {
 ...
 	memcpy(v, &a, sizeof(a));
 }

No more unaligned messages - but is this an acceptable solution?

thanks,
Jan
