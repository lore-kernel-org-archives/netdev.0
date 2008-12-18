From: "Fleming Andy-AFLEMING" <afleming@freescale.com>
Subject: Re: [PATCH v2.6.29 v3 5/5] gianfar: Continue polling until both tx and rx are empty
Date: Wed, 17 Dec 2008 20:40:20 -0600
Message-ID: <3034A747-1AD3-43FA-8939-67D654E3078A@freescale.com>
References: <1229550175-15600-3-git-send-email-afleming@freescale.com> <1229550175-15600-4-git-send-email-afleming@freescale.com> <1229550175-15600-5-git-send-email-afleming@freescale.com> <20081217.165440.259566423.davem@davemloft.net>
Mime-Version: 1.0 (iPhone Mail 5G77)
Content-Type: text/plain;
	format=flowed;
	delsp=yes;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Jeff Garzik" <jeff@garzik.org>, <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:43799 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750746AbYLRClF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2008 21:41:05 -0500
Received: from az33smr02.freescale.net (az33smr02.freescale.net [10.64.34.200])
	by az33egw02.freescale.net (8.14.3/az33egw02) with ESMTP id mBI2eraU005966
	for <netdev@vger.kernel.org>; Wed, 17 Dec 2008 19:40:53 -0700 (MST)
Received: from az33exm23.fsl.freescale.net (az33exm23.am.freescale.net [10.64.32.8])
	by az33smr02.freescale.net (8.13.1/8.13.0) with ESMTP id mBI2eqbs015509
	for <netdev@vger.kernel.org>; Wed, 17 Dec 2008 20:40:52 -0600 (CST)
In-Reply-To: <20081217.165440.259566423.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Dec 17, 2008, at 18:55, "David Miller" <davem@davemloft.net> wrote:

> From: Andy Fleming <afleming@freescale.com>
> Date: Wed, 17 Dec 2008 15:42:55 -0600
>
>> gfar_poll would declare polling done once the rx queue was empty,
>> but the tx queue could still have packets left.
>>
>> Stolen mostly from the e1000 driver.
>>
>> Signed-off-by: Andy Fleming <afleming@freescale.com>
>
> Applied.
>
> But I absolutely do not recommend this polling technique at all.
>
> The best scheme is to first purge your TX ring completely, and do not
> apply any quota to this work.  It's relatively cheap and batches well.
>
> Then, you process the RX ring and apply the quota only to the RX ring
> work.
>
> This is what every NAPI driver I've written does and it gives the best
> results.

I agree it seems a bit screwy, but I got a 4-5% performance increase.   
It may just require better tuning of my tx coalescing parameters-I was  
getting 7x the number of tx irqs as rx.
