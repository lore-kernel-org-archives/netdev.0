From: Enrico Mioso <mrkiko.rs@gmail.com>
Subject: Re: [PATCH net,stable] net: huawei_cdc_ncm: increase command buffer
 size
Date: Wed, 18 Jun 2014 18:32:58 +0200 (CEST)
Message-ID: <alpine.LNX.2.03.1406181831060.596@gmail.com>
References: <1403094084-13588-1-git-send-email-bjorn@mork.no> <1403100197.2266.14.camel@dcbw.local>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323328-1880649394-1403109181=:596"
Cc: =?ISO-8859-15?Q?Bj=F8rn_Mork?= <bjorn@mork.no>,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f173.google.com ([74.125.82.173]:64800 "EHLO
	mail-we0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753586AbaFRQci (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jun 2014 12:32:38 -0400
In-Reply-To: <1403100197.2266.14.camel@dcbw.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323328-1880649394-1403109181=:596
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: 8BIT

I am sorry - I am not in good conditions to perform the testing. But - I think 
it sould be fine anyway.
Sorry Bjorn. I might be able to do it in the weekend if you would like.
Enrico


On Wed, 18 Jun 2014, Dan Williams wrote:

==Date: Wed, 18 Jun 2014 16:03:17
==From: Dan Williams <dcbw@redhat.com>
==To: Bjørn Mork <bjorn@mork.no>
==Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
==    Enrico Mioso <mrkiko.rs@gmail.com>
==Subject: Re: [PATCH net,
==    stable] net: huawei_cdc_ncm: increase command buffer size
==
==On Wed, 2014-06-18 at 14:21 +0200, Bjørn Mork wrote:
==> Messages from the modem exceeding 256 bytes cause communication
==> failure.
==> 
==> The WDM protocol is strictly "read on demand", meaning that we only
==> poll for unread data after receiving a notification from the modem.
==> Since we have no way to know how much data the modem has to send,
==> we must make sure that the buffer we provide is "big enough".
==> Message truncation does not work. Truncated messages are left unread
==> until the modem has another message to send.  Which often won't
==> happen until the userspace application has given up waiting for the
==> final part of the last message, and therefore sends another command.
==> 
==> With a proper CDC WDM function there is a descriptor telling us
==> which buffer size the modem uses. But with this vendor specific
==> implementation there is no known way to calculate the exact "big
==> enough" number.  It is an unknown property of the modem firmware.
==> Experience has shown that 256 is too small.  The discussion of
==> this failure ended up concluding that 512 might be too small as
==> well. So 1024 seems like a reasonable value for now.
==> 
==> Fixes: 41c47d8cfd68 ("net: huawei_cdc_ncm: Introduce the huawei_cdc_ncm driver")
==> Cc: Enrico Mioso <mrkiko.rs@gmail.com>
==> Reported-by: Dan Williams <dcbw@redhat.com>
==> Signed-off-by: Bjørn Mork <bjorn@mork.no>
==
==Tested-by: Dan Williams <dcbw@redhat.com>
==
=='<CR><LF>^SYSCFGEX:
==("00","01","02","03","99"),((400380,"GSM900/GSM1800/WCDMA2100"),(6a80000,"GSM850/GSM1900/WCDMA850/AWS/WCDMA1900"),(3fffffff,"All bands")),(0-2),(0-4),((1081b,"LTE_B1/LTE_B2/LTE_B4/LTE_B5/LTE_B12/LTE_B17"),(7fffffffffffffff,"All bands"))<CR><LF><CR><LF>OK<CR><LF>'
==
==I get the last "<LF>" now :)
==
==> ---
==> 
==> The problem is a showstopper for anyone hitting it, so I believe this
==> fix should go into all maintained stable kernels with this driver.
==> That is anything based on v3.13 or newer.
==> 
==> Thanks,
==> Bjørn
==> 
==> 
==>  drivers/net/usb/huawei_cdc_ncm.c | 7 ++++---
==>  1 file changed, 4 insertions(+), 3 deletions(-)
==> 
==> diff --git a/drivers/net/usb/huawei_cdc_ncm.c b/drivers/net/usb/huawei_cdc_ncm.c
==> index f9822bc75425..5d95a13dbe2a 100644
==> --- a/drivers/net/usb/huawei_cdc_ncm.c
==> +++ b/drivers/net/usb/huawei_cdc_ncm.c
==> @@ -84,12 +84,13 @@ static int huawei_cdc_ncm_bind(struct usbnet *usbnet_dev,
==>  	ctx = drvstate->ctx;
==>  
==>  	if (usbnet_dev->status)
==> -		/* CDC-WMC r1.1 requires wMaxCommand to be "at least 256
==> -		 * decimal (0x100)"
==> +		/* The wMaxCommand buffer must be big enough to hold
==> +		 * any message from the modem. Experience has shown
==> +		 * that some replies are more than 256 bytes long
==>  		 */
==>  		subdriver = usb_cdc_wdm_register(ctx->control,
==>  						 &usbnet_dev->status->desc,
==> -						 256, /* wMaxCommand */
==> +						 1024, /* wMaxCommand */
==>  						 huawei_cdc_ncm_wdm_manage_power);
==>  	if (IS_ERR(subdriver)) {
==>  		ret = PTR_ERR(subdriver);
==
==
==
--8323328-1880649394-1403109181=:596--
