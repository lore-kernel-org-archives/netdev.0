From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch v1 1/2] Allow Mellanox network vendor to be configured if
 only I2C bus is configured
Date: Mon, 14 Aug 2017 09:00:52 +0200
Message-ID: <20170814070052.GB1855@nanopsycho>
References: <1502385112-103765-1-git-send-email-ohado@mellanox.com>
 <20170812143715.GN24282@mtr-leonro.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ohad Oz <ohado@mellanox.com>, davem@davemloft.net,
        netdev@vger.kernel.org, saeedm@mellanox.com, vadimp@mellanox.com,
        system-sw-low-level@mellanox.com
To: Leon Romanovsky <leon@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:37838 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750950AbdHNHAy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 14 Aug 2017 03:00:54 -0400
Received: by mail-wm0-f67.google.com with SMTP id t138so13343139wmt.4
        for <netdev@vger.kernel.org>; Mon, 14 Aug 2017 00:00:54 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170812143715.GN24282@mtr-leonro.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sat, Aug 12, 2017 at 04:37:15PM CEST, leon@kernel.org wrote:
>On Thu, Aug 10, 2017 at 05:11:51PM +0000, Ohad Oz wrote:
>> Patch allows Mellanox devices on system with no PCI, but with I2C only.
>>
>
>Did you test mlx5 device on such system? Did it work for you?

$ git grep i2c_add_driver drivers/net/ethernet/mellanox/
drivers/net/ethernet/mellanox/mlxsw/i2c.c:      return i2c_add_driver(i2c_driver);

That is the only driver that would probe on i2c, non-pci system.
mlx5 just would not probe, so there is nothing to test.



>
>What is the changelog between v0 and v1 of these patches?
>
>
>> Signed-off-by: Ohad Oz <ohado@mellanox.com>
>> ---
>>  drivers/net/ethernet/mellanox/Kconfig | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/drivers/net/ethernet/mellanox/Kconfig b/drivers/net/ethernet/mellanox/Kconfig
>> index 84a2007..0949741 100644
>> --- a/drivers/net/ethernet/mellanox/Kconfig
>> +++ b/drivers/net/ethernet/mellanox/Kconfig
>> @@ -5,7 +5,7 @@
>>  config NET_VENDOR_MELLANOX
>>  	bool "Mellanox devices"
>>  	default y
>> -	depends on PCI
>> +	depends on PCI || I2C
>>  	---help---
>>  	  If you have a network (Ethernet) card belonging to this class, say Y.
>>
>> --
>> 2.8.0
>>
