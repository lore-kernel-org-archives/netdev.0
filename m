From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH v2 2/4] ppp_mppe: check coherency counter for
 out-of-order sequencing
Date: Tue, 21 May 2013 11:36:17 -0700
Message-ID: <1369161377.3301.246.camel@edumazet-glaptop>
References: <1369160304-31967-1-git-send-email-jorge@dti2.net>
	 <1369160304-31967-2-git-send-email-jorge@dti2.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-ppp@vger.kernel.org
To: jorge@dti2.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:53646 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751764Ab3EUSgS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 May 2013 14:36:18 -0400
In-Reply-To: <1369160304-31967-2-git-send-email-jorge@dti2.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-05-21 at 20:18 +0200, Jorge Boncompte [DTI2] wrote:
> From: "Jorge Boncompte [DTI2]" <jorge@dti2.net>

>  	if (!state->stateful) {
> +		if (mppe_cmp_ccount(ccount, state->ccount) < 0) {
> +			if (net_ratelimit())
> +				printk(KERN_WARNING "%s[%d]: Dropping out-of-order "
> +				       "packet with ccount %u, "
> +				       "expecting %u!\n", __func__,
> +				       state->unit, ccount, state->ccount);
> +			return DECOMP_DROPERROR;
> +		}

You did not address my review, thats too bad.

WARNING: networking block comments don't use an empty /* line, use /* Comment...
#107: FILE: drivers/net/ppp/ppp_mppe.c:483:
+
+/*

WARNING: Prefer netdev_warn(netdev, ... then dev_warn(dev, ... then pr_warn(...  to printk(KERN_WARNING ...
#117: FILE: drivers/net/ppp/ppp_mppe.c:564:
+				printk(KERN_WARNING "%s[%d]: Dropping out-of-order "

WARNING: quoted string split across lines
#118: FILE: drivers/net/ppp/ppp_mppe.c:565:
+				printk(KERN_WARNING "%s[%d]: Dropping out-of-order "
+				       "packet with ccount %u, "
