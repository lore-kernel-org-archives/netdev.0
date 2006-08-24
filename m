From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 38/44] [IPV6] MIP6: Ignore to report if mobility
 headers is rejected.
Date: Wed, 23 Aug 2006 20:48:26 -0700 (PDT)
Message-ID: <20060823.204826.51517066.davem@davemloft.net>
References: <11563453672531-git-send-email-yoshfuji@linux-ipv6.org>
	<11563453674194-git-send-email-yoshfuji@linux-ipv6.org>
	<11563453671463-git-send-email-yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: anttit@tcs.hut.fi, vnuorval@tcs.hut.fi, netdev@vger.kernel.org,
	usagi-core@linux-ipv6.org, nakam@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:28058
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030267AbWHXDsY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 23:48:24 -0400
To: yoshfuji@linux-ipv6.org
In-Reply-To: <11563453671463-git-send-email-yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Thu, 24 Aug 2006 00:02:39 +0900

> Ignore to report user-space for known mobility headers rejected by
> destination options header transformation.
> Mobile IPv6 specification (RFC3775) says that mobility header
> is used with destination options header carrying home address option
> only for binding update message. Other type message cannot be used
> and node must drop it silently (and must not send binding error) if
> receving such packet.
> To achieve it, (1) application should use transformation policy and
> wild-card states to catch binding update message prior other packets
> (2) kernel doesn't report the reject to user-space not to send
> binding error message by application.
> This patch is for (2).
> Based on MIPL2 kernel patch.
> 
> This patch was also written by: Ville Nuorvala <vnuorval@tcs.hut.fi>
> 
> Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Applied to net-2.6.19.

> +	if (unlikely(fl->proto == IPPROTO_MH && fl->fl_mh_type <= IP6_MH_TYPE_MAX))
> +		goto out;
> +

It is another long line which can be split up for
readability :-)

Thank you.
