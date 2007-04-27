From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH][XFRM] export SPD info
Date: Fri, 27 Apr 2007 15:55:24 +0200
Message-ID: <463200CC.6010207@trash.net>
References: <1177681421.4059.2.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:49478 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755848AbXD0Nz3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Apr 2007 09:55:29 -0400
In-Reply-To: <1177681421.4059.2.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal wrote:
> +static int build_spdinfo(struct sk_buff *skb, u32 pid, u32 seq, u32 flags)
> +{
> +	struct xfrm_spdinfo si;
> +	struct nlmsghdr *nlh;
> +	u32 *f;
> +
> +	nlh = nlmsg_put(skb, pid, seq, XFRM_MSG_NEWSPDINFO, sizeof(u32), 0);
> +	if (nlh == NULL) /* shouldnt really happen ... */
> +		return -EMSGSIZE;
> +
> +	f = nlmsg_data(nlh);
> +	*f = flags;
> +	xfrm_spd_getinfo(&si);
> +
> +	if (flags & XFRM_SPD_HMASK)
> +		NLA_PUT_U32(skb, XFRMA_SPDHMASK, si.spdhcnt);
> +	if (flags & XFRM_SPD_HMAX)
> +		NLA_PUT_U32(skb, XFRMA_SPDHMAX, si.spdhmcnt);
> +	if (flags & XFRM_SPD_ICNT)
> +		NLA_PUT_U32(skb, XFRMA_SPDICNT, si.incnt);
> +	if (flags & XFRM_SPD_OCNT)
> +		NLA_PUT_U32(skb, XFRMA_SPDOCNT, si.outcnt);
> +	if (flags & XFRM_SPD_FCNT)
> +		NLA_PUT_U32(skb, XFRMA_SPDFCNT, si.fwdcnt);
> +	if (flags & XFRM_SPD_ISCNT)
> +		NLA_PUT_U32(skb, XFRMA_SPDISCNT, si.inscnt);
> +	if (flags & XFRM_SPD_OSCNT)
> +		NLA_PUT_U32(skb, XFRMA_SPDOSCNT, si.inscnt);
> +	if (flags & XFRM_SPD_FSCNT)
> +		NLA_PUT_U32(skb, XFRMA_SPDFSCNT, si.inscnt);


It it really worth the extra code for dumping them conditionally?
The attributes are neither large nor will they be sent very often.

