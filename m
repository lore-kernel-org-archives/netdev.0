From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCHv3, ipsec-next] xfrm: Do not parse 32bits compiled xfrm
 netlink msg on 64bits host
Date: Mon, 2 Feb 2015 09:44:43 +0100
Message-ID: <20150202084443.GS13046@secunet.com>
References: <1422349230-17394-1-git-send-email-fan.du@intel.com>
 <54CA0B9F.8080104@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Fan Du <fan.du@intel.com>, <herbert@gondor.apana.org.au>,
	<davem@davemloft.net>, <netdev@vger.kernel.org>,
	<fengyuleidian0615@gmail.com>
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:49231 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751053AbbBBIoq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Feb 2015 03:44:46 -0500
Content-Disposition: inline
In-Reply-To: <54CA0B9F.8080104@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 29, 2015 at 11:29:51AM +0100, Nicolas Dichtel wrote:
> A way to solve this problem was to provide to userland a xfrm compat header
> file, which match the ABI of the kernel. Something like:
> 
> #include <linux/xfrm.h>
> 
> #define xfrm_usersa_info xfrm_usersa_info_64
> #define xfrm_usersa_info_compat xfrm_usersa_info
> struct xfrm_usersa_info_compat {
> 	struct xfrm_selector		sel;
> 	struct xfrm_id			id;
> 	xfrm_address_t			saddr;
> 	struct xfrm_lifetime_cfg	lft;
> 	struct xfrm_lifetime_cur	curlft;
> 	struct xfrm_stats		stats;
> 	__u32				seq;
> 	__u32				reqid;
> 	__u16				family;
> 	__u8				mode;
> 	__u8				replay_window;
> 	__u8				flags;
> 	__u8				hole1;
> 	__u32				hole2;
> };
> 
> The point I try to make is that patching userland apps allows to use xfrm on a
> 32bits userland / 64bits kernel.

Ugh, I did not know that this is used that way. Which applications do this?
So the situation is worse than I thought. What happens to such applications
if we add a compat layer in the kernel? I'd guess they will break, right?

> 
> If I understand well your patch, it will not be possible anymore, all messages
> will be rejected. And this may break existing apps.

This patch would have been a quick solution without the case you
mentioned. Now I fear we can't fix all cases, something will remain
broken.
