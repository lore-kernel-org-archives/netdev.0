From: Brian Haley <brian.haley@hp.com>
Subject: Re: BNX2: Kernel crashes with 2.6.31 and 2.6.31.9
Date: Thu, 11 Mar 2010 16:57:58 -0500
Message-ID: <4B996766.5070509@hp.com>
References: <1268263973.9775.95.camel@nseg_linux_HP1.broadcom.com> <4B9850DC.9060703@hp.com> <1268329796.9775.125.camel@nseg_linux_HP1.broadcom.com> <20100311.100519.124285161.davem@davemloft.net> <1268332738.9775.133.camel@nseg_linux_HP1.broadcom.com> <4B994714.2040108@hp.com> <1268336848.9775.154.camel@nseg_linux_HP1.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"bonbons@linux-vserver.org" <bonbons@linux-vserver.org>,
	Benjamin Li <benli@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Michael Chan <mchan@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1268336848.9775.154.camel@nseg_linux_HP1.broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Chan wrote:
> On Thu, 2010-03-11 at 11:40 -0800, Brian Haley wrote:
>> I can only reproduce this on one system out of many, so it's either a
>> race condition or bad hardware.  The only thing I can confirm at the
>> moment is that it's the code at the bottom of bnx2_set_coalesce()
>> that's causing it, I'm trying to go through all those codepaths now.
> 
> The NETDEV WATCHDOG is caused by stopping the TX queues with
> ->trans_start older than dev->watchdog_timeo which is set to 5 seconds
> in bnx2.  Please try this patch below to update the ->trans_start first
> before stopping the TX queues:

Well I'm an idiot.  Someone had cherry-picked commit 4529819c4 (that caused
the reset_task bnx2 crash), so it was bad code in bnx2_netif_stop()/start()
that's already been fixed upstream.  I'll merge our bnx2 code up to the
firmware commit and start testing again to see if we still see the watchdog
timeouts we've seen in the past.

Thanks for your help.

-Brian
