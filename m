From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] be2net: make hwmon interface optional
Date: Tue, 19 May 2015 16:40:22 -0400 (EDT)
Message-ID: <20150519.164022.444377281915355405.davem@davemloft.net>
References: <2638325.2pcgKkR8vC@wuerfel>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, VenkatKumar.Duvvuru@emulex.com,
	sathya.perla@avagotech.com, ajit.khaparde@avagotech.com,
	padmanabh.ratnakar@avagotech.com,
	sriharsha.basavapatna@avagotech.com, linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47956 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750931AbbESUkZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2015 16:40:25 -0400
In-Reply-To: <2638325.2pcgKkR8vC@wuerfel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnd Bergmann <arnd@arndb.de>
Date: Mon, 18 May 2015 23:06:45 +0200

> The hwmon interface in the be2net driver causes a link error when
> be2net is built-in while the hwmon subsystem is a loadable module:
> 
> drivers/built-in.o: In function `be_probe':
> drivers/net/ethernet/emulex/benet/be_main.c:5761: undefined reference to `devm_hwmon_device_register_with_groups'
> 
> This adds a new Kconfig symbol, following the example of multiple
> other drivers that have the same problem. The new CONFIG_BE2NET_HWMON
> will not be available when (BE2NET=y && HWMON=m) to avoid this
> problem.
> 
> We have to also mark be_hwmon_show_temp as 'static' to ensure the
> compiler can optimize out all the unused code.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Fixes: 29e9122b3a ("be2net: Export board temperature using hwmon-sysfs interface.")

Applied, thanks.
