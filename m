From: Matthew Wilcox <matthew@wil.cx>
Subject: Re: [PATCH 1/9] PCI: vpd handle longer delays in access (rev3)
Date: Tue, 9 Sep 2008 14:23:09 -0600
Message-ID: <20080909202309.GE2772@parisc-linux.org>
References: <20080909182040.246073057@vyatta.com> <20080909182056.936398506@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jesse Barnes <jbarnes@virtuousgeek.org>, linux-pci@vger.kernel.org,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palinux.external.hp.com ([192.25.206.14]:39442 "EHLO
	mail.parisc-linux.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751663AbYIIUXZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2008 16:23:25 -0400
Content-Disposition: inline
In-Reply-To: <20080909182056.936398506@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 09, 2008 at 11:20:41AM -0700, Stephen Hemminger wrote:
> Accessing the VPD area can take a long time.  The existing 
> VPD access code fails consistently on my hardware. There are comments
> in the SysKonnect vendor driver that it can take up to 13ms per word. 
> 
> Change the access routines to:
>   * use a mutex rather than spinning with IRQ's disabled and lock held
>   * have a much longer timeout
>   * call cond_resched while spinning

> -		udelay(10);
> +		if (fatal_signal_pending(current))
> +			return -EINTR;
> +		cond_resched();

We're back to the hammering on the pci bus problem again.  However,
cond_resched() does tell us whether we rescheduled!

		if (!cond_resched())
			udelay(10);

-- 
Matthew Wilcox				Intel Open Source Technology Centre
"Bill, look, we understand that you're interested in selling us this
operating system, but compare it to ours.  We can't possibly take such
a retrograde step."
