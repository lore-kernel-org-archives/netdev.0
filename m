From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH 5/5] arm: convert omap ldp platform to use smsc911x
Date: Mon, 19 Jan 2009 22:35:41 +0000
Message-ID: <20090119223541.GK18301@n2100.arm.linux.org.uk>
References: <1232010482-3744-1-git-send-email-steve.glendinning@smsc.com> <1232010482-3744-2-git-send-email-steve.glendinning@smsc.com> <1232010482-3744-3-git-send-email-steve.glendinning@smsc.com> <1232010482-3744-4-git-send-email-steve.glendinning@smsc.com> <1232010482-3744-5-git-send-email-steve.glendinning@smsc.com> <1232010482-3744-6-git-send-email-steve.glendinning@smsc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-arm-kernel@lists.arm.linux.org.uk, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Stanley Miao <stanley.miao@windriver.com>,
	Ian Saturley <ian.saturley@smsc.com>
To: Steve Glendinning <steve.glendinning@smsc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caramon.arm.linux.org.uk ([78.32.30.218]:55184 "EHLO
	caramon.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751603AbZASWgA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2009 17:36:00 -0500
Content-Disposition: inline
In-Reply-To: <1232010482-3744-6-git-send-email-steve.glendinning@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 15, 2009 at 09:08:02AM +0000, Steve Glendinning wrote:
> -	ldp_smc911x_resources[0].start = cs_mem_base + 0x0;
> -	ldp_smc911x_resources[0].end   = cs_mem_base + 0xf;
> +	ldp_smsc911x_resources[0].start = cs_mem_base + 0x0;
> +	ldp_smsc911x_resources[0].end   = cs_mem_base + 0xf;

Actually, having finally got around to checking whether the smc911x
support submitted from the OMAP folk on the LDP board works, I find
it doesn't.

And the reason it doesn't is that SMC911x wants to claim 256 bytes
of space in this resource.  With only 16 bytes in the parent resource,
that isn't going to work.

It looks to me like this is wrong for the SMSC911x driver as well.

davem - I can see if I merge a fix for this (once I have confirmation
what the fix should be) and push it for -rc, that will make things a
little more complicated at your end.  Suggest we hold fire on these
patches for a few more days.
