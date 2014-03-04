From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v4 1/4] ieee802154: add generic header
 handling routines
Date: Tue, 04 Mar 2014 17:00:50 -0500 (EST)
Message-ID: <20140304.170050.2058599034902221847.davem@davemloft.net>
References: <1393943688-24221-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
	<1393943688-24221-2-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-zigbee-devel@lists.sourceforge.net
To: phoebe.buckheister@itwm.fraunhofer.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37497 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754890AbaCDWAw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2014 17:00:52 -0500
In-Reply-To: <1393943688-24221-2-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
Date: Tue,  4 Mar 2014 15:34:45 +0100

> +struct ieee802154_sechdr {
> +	u8 sc;
> +	u32 frame_ctr;
> +	union {
> +		struct {
> +			u16 pan_id;
> +			u16 short_addr;
> +		} pan;
> +		u8 hw[IEEE802154_ADDR_LEN];
> +	} key_source;
> +	u8 key_id;
> +};
> +
> +struct ieee802154_hdr {
> +	u16 fc;
> +	u8 seq;
> +	struct ieee802154_addr source;
> +	struct ieee802154_addr dest;
> +	struct ieee802154_sechdr sec;
> +};

You're going to have to address endianness both in these structure
definitions and the code.

For types larger than u8 you'll need to use __be16, __le16, __be32,
__le32 etc. as appropriate.

When setting/loading values, you'll need to use cpu_to_be16(),
cpu_to_le16() etc.  as appropriate.
