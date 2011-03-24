From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fix IP timestamp option (IPOPT_TS_PRESPEC) handling in
 ip_options_echo()
Date: Thu, 24 Mar 2011 16:20:05 -0700 (PDT)
Message-ID: <20110324.162005.71589730.davem@davemloft.net>
References: <1300988662-13204-1-git-send-email-jluebbe@debian.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jluebbe@debian.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34067
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934354Ab1CXXT0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Mar 2011 19:19:26 -0400
In-Reply-To: <1300988662-13204-1-git-send-email-jluebbe@debian.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jan Luebbe <jluebbe@debian.org>
Date: Thu, 24 Mar 2011 18:44:22 +0100

> -					if (soffset + 8 <= optlen) {
> +					if (soffset + 7 <= optlen) {

I don't see how you can legally reduce this check from 8 to 7 bytes.

> +						if (inet_addr_type(dev_net(skb_dst(skb)->dev), addr) != RTN_UNICAST) {
>  							dopt->ts_needtime = 1;
>  							soffset += 8;
>  						}

Yet keep this code which advances soffset by 8.
