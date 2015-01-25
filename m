From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net] net: ipv6: allow explicitly choosing optimistic
 addresses
Date: Sun, 25 Jan 2015 13:46:33 +0100
Message-ID: <1422189993.2148036.218504993.339586EE@webmail.messagingengine.com>
References: <1421823759-15098-1-git-send-email-ek@google.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: Erik Kline <ek@google.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:58302 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751537AbbAYMqe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Jan 2015 07:46:34 -0500
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id A6E9F207EA
	for <netdev@vger.kernel.org>; Sun, 25 Jan 2015 07:46:33 -0500 (EST)
In-Reply-To: <1421823759-15098-1-git-send-email-ek@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Wed, Jan 21, 2015, at 08:02, Erik Kline wrote:
>  		if (ipv6_addr_equal(&ifp->addr, addr) &&
> -                   !(ifp->flags&IFA_F_TENTATIVE) &&
> +                   (!(ifp->flags&IFA_F_TENTATIVE) ||
> +                    ifp->flags&IFA_F_OPTIMISTIC) &&
> +                   !(ifp->flags&banned_flags) &&
>  		    (dev == NULL || ifp->idev->dev == dev ||

Can the wrapper take the IFA_F_TENTATIVE and IFA_F_OPTIMISTIC into the
banned_flags argument, so this condition becomes easier to read? The new
caller could also specify them verbatim. I think it would improve
readability.

Thanks,
Hannes
