From: Ben Greear <greearb@candelatech.com>
Subject: Re: [BUG][debian-2.6.20-1-686] bridging + vlans + "vconfig rem" ==
 stuck kernel
Date: Wed, 09 May 2007 21:25:54 -0700
Message-ID: <46429ED2.10809@candelatech.com>
References: <2638DE26-D672-4245-BE88-D13B7F0F34A9@mac.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, LKML Kernel <linux-kernel@vger.kernel.org>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	OSDL Linux Bridging <bridge@osdl.org>
To: Kyle Moffett <mrmacman_g4@mac.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:37696 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754714AbXEJE0H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 May 2007 00:26:07 -0400
In-Reply-To: <2638DE26-D672-4245-BE88-D13B7F0F34A9@mac.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kyle Moffett wrote:
>
> vconfig       D 83CCD8CE     0 16564  16562                     (NOTLB)
>        efdd7e7c 00000086 ee120afb 83ccd8ce 98f00788 b7083ffa 5384b49a 
> c76c0b05
>        9ebaf791 00000004 efdd7e4e 00000007 f1468a90 2ab74174 00000362 
> 00000326
>        f1468b9c c180e420 00000001 00000286 c012933c efdd7e8c df98a000 
> c180e468
> Call Trace:
> [<c012933c>] lock_timer_base+0x15/0x2f
> [<c0129445>] __mod_timer+0x91/0x9b
> [<c02988f5>] schedule_timeout+0x70/0x8d
> [<f8b75209>] vlan_device_event+0x13/0xf8 [8021q]

Looks like a deadlock in the vlan code.  Any chance you can run this 
test with
lockdep enabled?

You could also add a printk in vlan_device_event() to check which event 
it is hanging on, and
the netdevice that is passed in.

Since the vlan code holds RTNL at this point, then most other network 
tasks will eventually
hang as well.

Thanks,
Ben


-- 
Ben Greear <greearb@candelatech.com> 
Candela Technologies Inc  http://www.candelatech.com


