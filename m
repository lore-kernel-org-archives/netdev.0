From: "Shimoda, Yoshihiro" <yoshihiro.shimoda.uh@renesas.com>
Subject: Re: [PATCH v2 5/5] net: sh_eth: use NAPI
Date: Mon, 14 May 2012 15:13:57 +0900
Message-ID: <4FB0A2A5.3060001@renesas.com>
References: <4FACD007.1070308@renesas.com>
 <1336750529.2874.69.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	SH-Linux <linux-sh@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relmlor3.renesas.com ([210.160.252.173]:49140 "EHLO
	relmlor3.renesas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753721Ab2ENGOX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 May 2012 02:14:23 -0400
In-reply-to: <1336750529.2874.69.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2012/05/12 0:35, Ben Hutchings wrote:
> On Fri, 2012-05-11 at 17:38 +0900, Shimoda, Yoshihiro wrote:
>> This patch modifies the driver to use NAPI.
> [...]
>> +static int sh_eth_poll(struct napi_struct *napi, int budget)
>> +{
< snip >
>> +	/* check whether the controller doesn't have any events */
>> +	if (!txfree_num && !(intr_status & cd->eesr_err_check) &&
>> +	    work_done < budget) {
>> +		napi_complete(napi);
> 
> If and only if you return a value less than the budget then you *must*
> call napi_complete().  You can't add these extra conditions.

Thank you for the point. I will fix it.

< snip >
> 
> You will also need to call napi_disable() and napi_enable() in the
> set_ringparam implementation.

I will add the code in sh_eth_set_ringparam().

> Ben.
> 

Best regards,
Yoshihiro Shimoda
