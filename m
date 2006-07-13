From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH 08/10] MLSXFRM: Add security context to acquire messages
 using PF_KEY
Date: Wed, 12 Jul 2006 21:52:57 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0607122149070.573@d.namei>
References: <44B56642.6060500@trustedcs.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, sds@tycho.nsa.gov, tjaeger@cse.psu.edu,
	selinux@tycho.nsa.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.sea5.speakeasy.net ([69.17.117.4]:56745 "EHLO
	mail2.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S1751456AbWGMBxA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Jul 2006 21:53:00 -0400
To: Venkat Yekkirala <vyekkirala@trustedcs.com>
In-Reply-To: <44B56642.6060500@trustedcs.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 12 Jul 2006, Venkat Yekkirala wrote:

> +static inline void security_xfrm_skb_secid(struct sk_buff *skb, u32 *secid)
> {
> -	return security_ops->xfrm_decode_session(skb, fl);
> +	BUG_ON(security_ops->xfrm_decode_session(skb, secid, 0));
> 

BUG_ON looks wrong here, in that you don't know why the LSM returned an 
error, and why should the box panic at this point at all?


-- 
James Morris
<jmorris@namei.org>
