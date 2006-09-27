From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 5/9][TG3]: Add tg3_poll_fw().
Date: Wed, 27 Sep 2006 16:47:02 -0400
Message-ID: <451AE346.9010801@garzik.org>
References: <1159389289.3411.22.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, linville@tuxdriver.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:54980 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1030824AbWI0UrJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2006 16:47:09 -0400
To: Michael Chan <mchan@broadcom.com>
In-Reply-To: <1159389289.3411.22.camel@rh4>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Chan wrote:
> +	/* Chip might not be fitted with firmware.  Some Sun onboard
> +	 * parts are configured like that.  So don't signal the timeout
> +	 * of the above loop as an error, but do report the lack of
> +	 * running firmware once.
> +	 */
> +	if (i >= 100000 &&
> +	    !(tp->tg3_flags2 & TG3_FLG2_NO_FWARE_REPORTED)) {
> +		tp->tg3_flags2 |= TG3_FLG2_NO_FWARE_REPORTED;
> +
> +		printk(KERN_INFO PFX "%s: No firmware running.\n",
> +		       tp->dev->name);
> +	}
> +
> +	return 0;

You need to actually return failure, for the failure case.

Currently, this function is written to return an error code, but always 
returns zero.

	Jeff



