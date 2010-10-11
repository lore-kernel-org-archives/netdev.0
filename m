From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] atl1c: Add support for Atheros AR8152 and AR8152
Date: Mon, 11 Oct 2010 12:01:28 -0700
Message-ID: <20101011120128.2cd460c9@nehalam>
References: <1286759930.2955.285.camel@localhost>
	<20101010.210304.71107535.davem@davemloft.net>
	<20101011184835.GA10049@tux>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"ben@decadent.org.uk" <ben@decadent.org.uk>,
	Luis Rodriguez <Luis.Rodriguez@Atheros.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jie Yang <Jie.Yang@atheros.com>, <linux-team@atheros.com>
To: "Luis R. Rodriguez" <lrodriguez@atheros.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:36057 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753455Ab0JKTBb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Oct 2010 15:01:31 -0400
In-Reply-To: <20101011184835.GA10049@tux>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 11 Oct 2010 11:48:35 -0700
"Luis R. Rodriguez" <lrodriguez@atheros.com> wrote:

> On Sun, Oct 10, 2010 at 09:03:04PM -0700, David Miller wrote:
> > From: Ben Hutchings <ben@decadent.org.uk>
> > Date: Mon, 11 Oct 2010 02:18:50 +0100
> > 
> > > Your commit 496c185c9495629ef1c65387cb2594578393cfe0 "atl1c: Add support
> > > for Atheros AR8152 and AR8152" included the following changes:
> >  ...
> > >> +		if (hw->nic_type == athr_l1c || hw->nic_type == athr_l2c_b) {
> >  ...
> > >> +	if ((hw->nic_type == athr_l1c || hw->nic_type == athr_l2c)) {
> >  ...
> > > Shouldn't the first if-statement use the same condition as the second
> > > i.e. matching the previously-defined hardware types athr_l1c and
> > > athr_l2c?
> > 
> > Yeah that definitely looks like a bug to me.
> 
> Good catch, unfortunatley I don't have the source code I used to port
> this work the day I did this anymore locally, so adding 
> Jie Yang who is actually our maintainer for this driver.
> 
> Jie, can you please confirm if this patch is correct?
> 
> diff --git a/drivers/net/atl1c/atl1c_hw.c b/drivers/net/atl1c/atl1c_hw.c
> index d8501f0..0a7b786 100644
> --- a/drivers/net/atl1c/atl1c_hw.c
> +++ b/drivers/net/atl1c/atl1c_hw.c
> @@ -132,7 +132,7 @@ static int atl1c_get_permanent_address(struct atl1c_hw *hw)
>  			return -1;
>  	}
>  	/* Disable OTP_CLK */
> -	if ((hw->nic_type == athr_l1c || hw->nic_type == athr_l2c)) {
> +	if ((hw->nic_type == athr_l1c || hw->nic_type == athr_l2c_b)) {
>  		otp_ctrl_data &= ~OTP_CTRL_CLK_EN;
>  		AT_WRITE_REG(hw, REG_OTP_CTRL, otp_ctrl_data);
>  		msleep(1);
> 

Did you notice ((gratuitous extra parens))


-- 
