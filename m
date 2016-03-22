From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RESEND] net: ipv4: Fix truncated timestamp returned by
 inet_current_timestamp()
Date: Mon, 21 Mar 2016 22:57:49 -0400 (EDT)
Message-ID: <20160321.225749.1021493391392469038.davem@davemloft.net>
References: <1458609686-7435-1-git-send-email-deepa.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, y2038@lists.linaro.org,
	kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org, jmorris@namei.org,
	kaber@trash.net, arnd@arndb.de
To: deepa.kernel@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57187 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757947AbcCVC54 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Mar 2016 22:57:56 -0400
In-Reply-To: <1458609686-7435-1-git-send-email-deepa.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Deepa Dinamani <deepa.kernel@gmail.com>
Date: Mon, 21 Mar 2016 18:21:26 -0700

> The millisecond timestamps returned by the function is
> converted to network byte order by making a call to htons().
> htons() only returns __be16 while __be32 is required here.
> 
> This was identified by the sparse warning from the buildbot:
> net/ipv4/af_inet.c:1405:16: sparse: incorrect type in return
> 			    expression (different base types)
> net/ipv4/af_inet.c:1405:16: expected restricted __be32
> net/ipv4/af_inet.c:1405:16: got restricted __be16 [usertype] <noident>
> 
> Change the function to use htonl() to return the correct __be32 type
> instead so that the millisecond value doesn't get truncated.
> 
> Signed-off-by: Deepa Dinamani <deepa.kernel@gmail.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
> Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
> Cc: James Morris <jmorris@namei.org>
> Cc: Patrick McHardy <kaber@trash.net>
> Cc: Arnd Bergmann <arnd@arndb.de>
> Fixes: 822c868532ca ("net: ipv4: Convert IP network timestamps to be y2038 safe")
> Reported-by: Fengguang Wu <fengguang.wu@intel.com> [0-day test robot]

Applied and queued up for -stable.
