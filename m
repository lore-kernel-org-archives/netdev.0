From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/1] net: rmnet_data: Initial implementation
Date: Tue, 07 Mar 2017 12:14:17 -0800 (PST)
Message-ID: <20170307.121417.1835754162077665274.davem@davemloft.net>
References: <1487907054-15129-1-git-send-email-subashab@codeaurora.org>
        <1487907054-15129-2-git-send-email-subashab@codeaurora.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fengguang.wu@intel.com
To: subashab@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36250 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932639AbdCGUYd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Mar 2017 15:24:33 -0500
In-Reply-To: <1487907054-15129-2-git-send-email-subashab@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Date: Thu, 23 Feb 2017 20:30:54 -0700

> +struct rmnet_nl_msg_s {
> +	uint16_t reserved;
> +	uint16_t message_type;
> +	uint16_t reserved2:14;
> +	uint16_t crd:2;

Inside the kernel you should use "u32", "u16", "u8", etc. for purely
internal things, and for datastructures exported to userspace you
should use "__u32", "__u16", "__u8".

Furthermore, if the members have specific endianness you should
properly use the "__le32", "__le16", "__be32", "__be16" etc. types.

> +/**
> + * rmnet_vnd_ioctl() - IOCTL NDO callback

Please use netlink for device instantiation and configuration
rather than ioctls.
