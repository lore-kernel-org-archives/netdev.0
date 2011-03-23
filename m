From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 08/16] mlx4_en: Reporting HW revision in ethtool -i
Date: Wed, 23 Mar 2011 12:34:27 -0700 (PDT)
Message-ID: <20110323.123427.242111674.davem@davemloft.net>
References: <4D89B16F.4040008@mellanox.co.il>
	<1300889054.26693.527.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yevgenyp@mellanox.co.il, netdev@vger.kernel.org,
	eugenia@mellanox.co.il
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39801
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756648Ab1CWTds (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Mar 2011 15:33:48 -0400
In-Reply-To: <1300889054.26693.527.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Wed, 23 Mar 2011 14:04:14 +0000

> On Wed, 2011-03-23 at 10:38 +0200, Yevgeny Petrilin wrote:
>> HW revision is derived from device ID and rev id.
> [...]
>> -	sprintf(drvinfo->driver, DRV_NAME " (%s)", mdev->dev->board_id);
>> +	switch (mdev->dev->rev_id) {
>> +	case 0xa0:
>> +		if (dev->dev_id >= MLX4_EN_CX3_LOW_ID && dev->dev_id <= MLX4_EN_CX3_HIGH_ID)
>> +			sprintf(drvinfo->driver, DRV_NAME " (%s_CX-3)", mdev->dev->board_id);
>> +		else
>> +			sprintf(drvinfo->driver, DRV_NAME " (%s_CX)", mdev->dev->board_id);
>> +		break;
>> +	case 0xb0:
>> +		sprintf(drvinfo->driver, DRV_NAME " (%s_CX-2)", mdev->dev->board_id);
>> +		break;
>> +	default:
>> +		sprintf(drvinfo->driver, DRV_NAME " (%s)", mdev->dev->board_id);
>> +		break;
> [...]
> 
> This is an abuse of the ethtool_drvinfo::driver field.
> 
> Your users can use lspci -v, can't they?

Agreed, mlx4 folks please send me a follow-up patch that removes this
conditional string.

The driver string is only meant to identify the software, not the
hardware variant.
