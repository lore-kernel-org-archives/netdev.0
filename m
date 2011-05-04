From: Ming Lei <tom.leiming@gmail.com>
Subject: Re: [PATCH] usbnet: runtime pm: fix out of memory
Date: Wed, 4 May 2011 14:59:41 +0800
Message-ID: <BANLkTinZK_qjO7u+ckG_83_paVyMeyrgPw@mail.gmail.com>
References: <1304066229-30875-1-git-send-email-tom.leiming@gmail.com>
	<20110502.155214.179953741.davem@davemloft.net>
	<201105030953.44131.oneukum@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org
To: Oliver Neukum <oneukum@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:49887 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752499Ab1EDG7m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2011 02:59:42 -0400
In-Reply-To: <201105030953.44131.oneukum@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

2011/5/3 Oliver Neukum <oneukum@suse.de>:

> Do the devices in question use cdc_ether?

No, the device is smsc95xx, which is compound device and is
integrated into pandaboard.

> The problem I see with this patch is that cdc_ether uses .reset_resume = usbnet_resume
> Therefore the device will not have been reset from the viewpoint of the device, yet
> the device may be open, so the bug would strike again.
>
> It seems to me that this patch is not wrong as such, but incomplete.

Since it is not cdc device, so the patch should be complete, the idea behind
the patch is reasonable: only start to schedule urb for data packets after the
interface is opened.

Even from the comment below in usbnet_open, it is a generic fix for
this kind of issue, we should always put the device into a 'known safe" state
before starting communication.

    int usbnet_open (struct net_device *net)
         ......
         // put into "known safe" state
         ......

thanks,
-- 
Ming Lei
