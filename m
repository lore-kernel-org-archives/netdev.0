From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 01/10] devlink: Add permanent config
 parameter get/set operations
Date: Wed, 25 Oct 2017 11:53:24 +0900 (KST)
Message-ID: <20171025.115324.226089199287535265.davem@davemloft.net>
References: <1508875962-39233-1-git-send-email-steven.lin1@broadcom.com>
        <1508875962-39233-2-git-send-email-steven.lin1@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@mellanox.com,
        michael.chan@broadcom.com, linville@tuxdriver.com,
        gospo@broadcom.com, yuvalm@mellanox.com
To: steven.lin1@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42638 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751899AbdJYCxd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Oct 2017 22:53:33 -0400
In-Reply-To: <1508875962-39233-2-git-send-email-steven.lin1@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Lin <steven.lin1@broadcom.com>
Date: Tue, 24 Oct 2017 16:12:33 -0400

> +	switch (type) {
> +	case NLA_U8:
> +		val = *((u8 *)value);
> +		if (nla_put_u8(msg, DEVLINK_ATTR_PERM_CONFIG_VALUE, val))
> +			goto nest_err;
> +		break;
> +	case NLA_U16:
> +		val = *((u16 *)value);
> +		if (nla_put_u16(msg, DEVLINK_ATTR_PERM_CONFIG_VALUE, val))
> +			goto nest_err;
> +		break;
> +	case NLA_U32:
> +		val = *((u32 *)value);
> +		if (nla_put_u32(msg, DEVLINK_ATTR_PERM_CONFIG_VALUE, val))
> +			goto nest_err;
> +		break;
> +	}
> +	nla_nest_end(msg, param_attr);
> +
> +	kfree(value);

You have to get the endianness right on these things.  Netlink could
theoretically be done over a network, so just saying "device and
system endianness match" is not a valid argument.

Typing and endianness is so important for interfaces like this, so
please contruct the interfaces such that the compiler and 'sparse' can
help us make sure it is done properly.

Thanks.
