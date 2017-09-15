From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 2/2] Staging: irda: Remove parentheses on the right of
 assignment
Date: Fri, 15 Sep 2017 14:31:48 -0700
Message-ID: <1505511108.27581.16.camel@perches.com>
References: <cover.1505508423.git.srishtishar@gmail.com>
         <9380189edb2722544981c868699ade29ab5c297d.1505508423.git.srishtishar@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: gregkh@linuxfoundation.org, netdev@vger.kernel.org,
        devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org,
        outreachy-kernel@googlegroups.com
To: Srishti Sharma <srishtishar@gmail.com>, samuel@sortiz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0175.hostedemail.com ([216.40.44.175]:53951 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1750873AbdIOVbw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 15 Sep 2017 17:31:52 -0400
In-Reply-To: <9380189edb2722544981c868699ade29ab5c297d.1505508423.git.srishtishar@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2017-09-16 at 02:36 +0530, Srishti Sharma wrote:
> Parentheses are not needed on the right hand side of assignment
> statement in most cases. Done using the following semantic
> patch by coccinelle.
[]
> @@
> identifier E,F,G,f;
> expression e,r;
> @@
> 
> (
> E = (G == F);
> > 
> 
> E = (e == r);
> > 
> 
> E =
> -(
> ...
> -)
> ;
> )
[]
> diff --git a/drivers/staging/irda/drivers/mcs7780.c b/drivers/staging/irda/drivers/mcs7780.c
[]
> @@ -605,7 +605,7 @@ static int mcs_speed_change(struct mcs_cb *mcs)
>  	if (mcs->new_speed <= 115200) {
>  		rval &= ~MCS_FIR;
>  
> -		rst = (mcs->speed > 115200);
> +		rst = mcs->speed > 115200;
>  		if (rst)
>  			mcs_set_reg(mcs, MCS_MINRXPW_REG, 0);

Coccinelle is a good tool, but its output is limited to
the correctness
and completeness of its input script.

Please look at the suggested modifications of the script
and examine the code for other similar uses.

The else if block immediately below this is:

	} else if (mcs->new_speed <= 1152000) {
		rval &= ~MCS_FIR;

		if ((rst = !(mcs->speed == 576000 || mcs->speed == 11520
00)))
			mcs_set_reg(mcs, MCS_MINRXPW_REG, 5);

which should also be corrected by this patch.
