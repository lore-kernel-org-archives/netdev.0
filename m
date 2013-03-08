From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tg3: Update link_up flag for phylib devices
Date: Fri, 08 Mar 2013 13:15:42 -0500 (EST)
Message-ID: <20130308.131542.1894554320106573944.davem@davemloft.net>
References: <1362765684-5265-1-git-send-email-nsujir@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hirofumi@mail.parknet.co.jp,
	stable@vger.kernel.org, mchan@broadcom.com
To: nsujir@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57624 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934561Ab3CHSPo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Mar 2013 13:15:44 -0500
In-Reply-To: <1362765684-5265-1-git-send-email-nsujir@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Nithin Nayak Sujir" <nsujir@broadcom.com>
Date: Fri, 8 Mar 2013 10:01:24 -0800

> Commit f4a46d1f46a8fece34edd2023e054072b02e110d introduced a bug where
> the ifconfig stats would remain 0 for phylib devices. This is due to
> tp->link_up flag never becoming true causing tg3_periodic_fetch_stats()
> to return.
> 
> The link_up flag was being updated in tg3_test_and_report_link_chg()
> after setting up the phy. This function however, is not called for
> phylib devices since the driver does not do the phy setup.
> 
> This patch moves the link_up flag update into the common
> tg3_link_report() function that gets called for phylib devices as well
> for non phylib devices when the link state changes.
> 
> To avoid updating link_up twice, we replace tg3_carrier_...() calls that
> are followed by tg3_link_report(), with netif_carrier_...(). We can then
> remove the unused tg3_carrier_on() function.
> 
> CC: <stable@vger.kernel.org>
> Reported-by: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
> Signed-off-by: Nithin Nayak Sujir <nsujir@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied, thanks.
