From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 16626] New: Machine hangs with EIP at
 skb_copy_and_csum_dev
Date: Thu, 19 Aug 2010 15:21:43 -0700
Message-ID: <20100819152143.8a57c465.akpm@linux-foundation.org>
References: <bug-16626-10286@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, pvp-lsts@fs.uni-ruse.bg
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:58206 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751846Ab0HSWW0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Aug 2010 18:22:26 -0400
In-Reply-To: <bug-16626-10286@https.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Thu, 19 Aug 2010 09:57:25 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=16626
> 
>            Summary: Machine hangs with EIP at skb_copy_and_csum_dev
>            Product: Drivers
>            Version: 2.5
>     Kernel Version: 2.6.36-rc1-00127-g763008c
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: blocking
>           Priority: P1
>          Component: PCI
>         AssignedTo: drivers_pci@kernel-bugs.osdl.org
>         ReportedBy: pvp-lsts@fs.uni-ruse.bg
>         Regression: Yes

A post-2.6.35 regression.

> 
> After upgrade from 2.6.33.7 to 2.6.35.2 a server hanged twice, so
> continued on 2.6.33.7.
> 
> Today decided to try lates Linus' tree with no luck.
> 
> The first time I started on 2.6.36-rc1-00127-g763008c it ran for a few
> minutes, then whent dead with this on the screen:
> [picture 1]
> http://picpaste.com/9cfb03116d41f27568e1bb2a67b7f4dc.jpg
> 
> [picture 2]
> Then I power-cycled the machine, only two get this:
> http://picpaste.com/6d70f453e462d1aed038781ad4bdb741.jpg
> 
> And because [picture 2] seemed too bad on the lower half of the screen,
> here is 
> [picture 3]
> http://picpaste.com/0a51ae079ace2e4abd9e9d29226069f7.jpg

Might have triggered the BUG_ON() in skb_copy_and_csum_dev().  Might be
a tg3 thing.  Hard to tell.

It'd be really nice to get that first screenful.  Sigh.  How long have
we had this oops-scrolls-off problem??  Perhaps you could set
/proc/sys/kernel/printk_delay to 100 (it's in milliseconds) so that the
oops scrolls past nice and slowly?

