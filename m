From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: Re: [PATCH] gianfar: ethernet vanishes after restoring from hibernation
Date: Fri, 9 Nov 2012 18:02:12 +0200
Message-ID: <509D2904.8050602@freescale.com>
References: <1352181848-24102-1-git-send-email-dongsheng.wang@freescale.com> <1352472231-17927-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>,
	Wang Dongsheng <dongsheng.wang@freescale.com>
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [216.32.180.186] ([216.32.180.186]:12171 "EHLO
	co1outboundpool.messaging.microsoft.com" rhost-flags-FAIL-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752914Ab2KIQDx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Nov 2012 11:03:53 -0500
In-Reply-To: <1352472231-17927-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/9/2012 4:43 PM, Paul Gortmaker wrote:
> From: Wang Dongsheng <dongsheng.wang@freescale.com>
>
> If a gianfar ethernet device is down prior to hibernating a
> system, it will no longer be present upon system restore.
>
> For example:
>
> 	~# ifconfig eth0 down
> 	~# echo disk > /sys/power/state
>
> 	  <trigger a restore from hibernation>
>
> 	~# ifconfig eth0 up
> 	SIOCSIFFLAGS: No such device
>
> This happens because the restore function bails out early upon
> finding devices that were not up at hibernation.  In doing so,
> it never gets to the netif_device_attach call at the end of
> the restore function.  Adding the netif_device_attach as done
> here also makes the gfar_restore code consistent with what is
> done in the gfar_resume code.
>
> Cc: Claudiu Manoil <claudiu.manoil@freescale.com>

Hello Paul,

Thought I don't have the proper setup to test the hibernation feature,
I agree with this patch especially now that the description is much
clearer. I fully agree on the consistency argument b/w gfar_restore and
gfar_resume. (good observation)

Acked-by: Claudiu Manoil <claudiu.manoil@freescale.com>
