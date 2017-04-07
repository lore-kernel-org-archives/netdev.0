From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC 1/3] netlink: extended error reporting
Date: Fri, 07 Apr 2017 21:41:03 +0200
Message-ID: <1491594063.5800.15.camel@sipsolutions.net>
References: <20170407182620.6438-1-johannes@sipsolutions.net>
         <20170407182620.6438-2-johannes@sipsolutions.net>
         (sfid-20170407_202644_889879_CEBB983B)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: pablo@netfilter.org
To: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:52044 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752219AbdDGTlH (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 7 Apr 2017 15:41:07 -0400
In-Reply-To: <20170407182620.6438-2-johannes@sipsolutions.net> (sfid-20170407_202644_889879_CEBB983B)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-04-07 at 20:26 +0200, Johannes Berg wrote:
> 
> +	if (nlk->flags & NETLINK_F_EXT_ACK) {
> +		if (exterr && exterr->msg)
> +			WARN_ON(nla_put_string(skb,
> NLMSGERR_ATTR_MSG,
> +					       exterr->msg));
> +		if (exterr && exterr->msg_offset)
> +			WARN_ON(nla_put_u32(skb, NLMSGERR_ATTR_OFFS,
> +					    exterr->msg_offset));
> +		if (exterr && exterr->attr)
> +			WARN_ON(nla_put_u16(skb, NLMSGERR_ATTR_ATTR,
> +					    exterr->attr));
> +	}

I forgot to check (err != 0) here, which can cause inconsistencies -
noticed that while just adding the error case Jamal wanted. I'll send
out that as a separate patch, and squash it later when I resubmit.

johannes
