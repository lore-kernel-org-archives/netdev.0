From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Lockdep splat for rt8169
Date: Sat, 7 May 2011 20:15:58 +0200
Message-ID: <20110507181558.GA20456@electric-eye.fr.zoreil.com>
References: <4DC1CB8F.8080905@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:35413 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755907Ab1EGSZY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 May 2011 14:25:24 -0400
Content-Disposition: inline
In-Reply-To: <4DC1CB8F.8080905@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Greear <greearb@candelatech.com> :
[...]
> Seems to be the first post 2.6.38 kernel that will boot stable
> on this system!

You are spoiled. I have to merge davem-next with -git or my raid1
test machine is unusable. :o/

> I previously reported the timer issue, but perhaps the lock
> debugging will help.

It is the same problem and will be triggered by any driver changing
the link state from an hard irq context - the r8169 driver is not
alone.

If you want a q'n'd workaround for the r8169 driver, defering its
LinkChg processing from the irq handler to a work task may do the
trick.

I am not sure what the general fix is:
- do more or less the same for linkwatch (i.e. defer more work to
  a user context)
- audit each driver
- ???

-- 
Ueimor
