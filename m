From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH 1/2] net: Add layer 2 hardware acceleration operations
 for macvlan devices
Date: Mon, 14 Oct 2013 06:48:45 -0400
Message-ID: <20131014104845.GB26880@hmsreliant.think-freely.org>
References: <1380140209-24587-1-git-send-email-nhorman@tuxdriver.com>
 <1381517037-26007-1-git-send-email-nhorman@tuxdriver.com>
 <1381517037-26007-2-git-send-email-nhorman@tuxdriver.com>
 <525B0689.4070109@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Andy Gospodarek <andy@greyhouse.net>,
	David Miller <davem@davemloft.net>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:49876 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755782Ab3JNKsx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Oct 2013 06:48:53 -0400
Content-Disposition: inline
In-Reply-To: <525B0689.4070109@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 13, 2013 at 01:46:01PM -0700, John Fastabend wrote:
> On 10/11/2013 11:43 AM, Neil Horman wrote:
> >Add a operations structure that allows a network interface to export the fact
> >that it supports package forwarding in hardware between physical interfaces and
> >other mac layer devices assigned to it (such as macvlans).  this operaions
> >structure can be used by virtual mac devices to bypass software switching so
> >that forwarding can be done in hardware more efficiently.
> >
> >Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> >CC: john.fastabend@gmail.com
> >CC: Andy Gospodarek <andy@greyhouse.net>
> >CC: "David S. Miller" <davem@davemloft.net>
> >---
> 
> [...]
> 
> >
> >diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> >index 2ddb48d..1710fdb 100644
> >--- a/include/linux/skbuff.h
> >+++ b/include/linux/skbuff.h
> >@@ -426,9 +426,9 @@ struct sk_buff {
> >  	char			cb[48] __aligned(8);
> >
> >  	unsigned long		_skb_refdst;
> >-#ifdef CONFIG_XFRM
> >+
> 
> Is this a hold-over from the previous patches? 'sp' isn't touched
> anywhere else so put the ifdef/endif back.
> 
Yeah, my screw up, I wanted to get this out before the weekend and missed that
screw up.  Sorry.

Neil

> >  	struct	sec_path	*sp;
> >-#endif
> >+
> >  	unsigned int		len,
> >  				data_len;
> >  	__u16			mac_len,
> >diff --git a/net/core/dev.c b/net/core/dev.c
> >index 5c713f2..ecad8c2 100644
> 
> -- 
> John Fastabend         Intel Corporation
> 
