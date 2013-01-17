From: Peter Korsgaard <jacmet@sunsite.dk>
Subject: Re: [PATCH] net: usb: initialize tmp in dm9601.c to avoid warning
Date: Thu, 17 Jan 2013 23:47:58 +0100
Message-ID: <87wqvbjujl.fsf@dell.be.48ers.dk>
References: <1358450989-25205-1-git-send-email-sque@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, msb@chromium.org
To: Simon Que <sque@chromium.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:54671 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753644Ab3AQWsK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2013 17:48:10 -0500
Received: by mail-ee0-f46.google.com with SMTP id e49so1517880eek.33
        for <netdev@vger.kernel.org>; Thu, 17 Jan 2013 14:48:09 -0800 (PST)
In-Reply-To: <1358450989-25205-1-git-send-email-sque@chromium.org> (Simon
	Que's message of "Thu, 17 Jan 2013 11:29:49 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>>>> "Simon" == Simon Que <sque@chromium.org> writes:

 Simon> In two places, tmp is initialized implicitly by being passed as a
 Simon> pointer during a function call.  However, this is not obvious to the
 Simon> compiler, which logs a warning.

What warning and what compiler version are you using?


 Simon> Signed-off-by: Simon Que <sque@chromium.org>
 Simon> ---
 Simon>  drivers/net/usb/dm9601.c |    4 ++--
 Simon>  1 files changed, 2 insertions(+), 2 deletions(-)

 Simon> diff --git a/drivers/net/usb/dm9601.c b/drivers/net/usb/dm9601.c
 Simon> index e0433ce..94e716d 100644
 Simon> --- a/drivers/net/usb/dm9601.c
 Simon> +++ b/drivers/net/usb/dm9601.c
 Simon> @@ -199,7 +199,7 @@ static int dm_read_shared_word(struct usbnet *dev, int phy, u8 reg, __le16 *valu
 Simon>  	dm_write_reg(dev, DM_SHARED_CTRL, phy ? 0xc : 0x4);
 
 Simon>  	for (i = 0; i < DM_TIMEOUT; i++) {
 Simon> -		u8 tmp;
 Simon> +		u8 tmp = 0;
 
 Simon>  		udelay(1);
 Simon>  		ret = dm_read_reg(dev, DM_SHARED_CTRL, &tmp);
 Simon> @@ -242,7 +242,7 @@ static int dm_write_shared_word(struct usbnet *dev, int phy, u8 reg, __le16 valu
 Simon>  	dm_write_reg(dev, DM_SHARED_CTRL, phy ? 0x1a : 0x12);
 
 Simon>  	for (i = 0; i < DM_TIMEOUT; i++) {
 Simon> -		u8 tmp;
 Simon> +		u8 tmp = 0;
 
 Simon>  		udelay(1);
 Simon>  		ret = dm_read_reg(dev, DM_SHARED_CTRL, &tmp);
 Simon> -- 
 Simon> 1.7.8.6



-- 
Bye, Peter Korsgaard
