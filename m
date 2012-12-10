From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 02/22] bnx2x: VF <-> PF channel 'acquire'
 at vf probe
Date: Mon, 10 Dec 2012 13:37:46 -0500 (EST)
Message-ID: <20121210.133746.1285652256550314707.davem@davemloft.net>
References: <1355154406-10855-1-git-send-email-ariele@broadcom.com>
	<1355154406-10855-3-git-send-email-ariele@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: ariele@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58363 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750930Ab2LJShs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Dec 2012 13:37:48 -0500
In-Reply-To: <1355154406-10855-3-git-send-email-ariele@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Ariel Elior" <ariele@broadcom.com>
Date: Mon, 10 Dec 2012 17:46:26 +0200

> +/* VF MBX (aka vf-pf channel) */
> +#include "bnx2x.h"
> +#include "bnx2x_sriov.h"
> +/* place a given tlv on the tlv buffer at a given offset */
> +void bnx2x_add_tlv(struct bnx2x *bp, void *tlvs_list, u16 offset, u16 type,
> +		   u16 length)

Put an empty line between include directives and the rest of the
file.

> +	while (tlv->type != CHANNEL_TLV_LIST_END) {
> +
> +		/* output tlv */
> +		DP(BNX2X_MSG_IOV, "TLV number %d: type %d, length %d\n", i,
> +		   tlv->type, tlv->length);

But this is a place where an empty line is not appropriate, please remove
the empty line after the one with the while().

> +/* acquire response tlv - carries the allocated resources */
> +struct pfvf_acquire_resp_tlv {
> +	struct pfvf_tlv hdr;
> +	struct pf_vf_pfdev_info {
> +		u32 chip_num;
> +		u32 pf_cap;
> +		#define PFVF_CAP_RSS		0x00000001
> +		#define PFVF_CAP_DHC		0x00000002
> +		#define PFVF_CAP_TPA		0x00000004

Please don't indent CPP defines excessively like this, they should be
at or near the initial column so that CPP directives can be easily
spotted by someone reading this code.
