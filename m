From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH -next 2/5] net: sched: use counter to break reclassify
 loops
Date: Tue, 05 May 2015 12:47:22 +0200
Message-ID: <55489FBA.8030908@iogearbox.net>
References: <1430765318-13788-1-git-send-email-fw@strlen.de> <1430765318-13788-3-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, alexei.starovoitov@gmail.com
To: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:58502 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757913AbbEEKr3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2015 06:47:29 -0400
In-Reply-To: <1430765318-13788-3-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/04/2015 08:48 PM, Florian Westphal wrote:
> Seems all we want here is to avoid endless 'goto reclassify' loop.
> tc_classify_compat even resets this counter when something other
> than TC_ACT_RECLASSIFY is returned, so this skb-counter doesn't
> break hypothetical loops induced by something other than perpetual
> TC_ACT_RECLASSIFY return values.
>
> skb_act_clone is now identical to skb_clone, so just use that.
>
> Tested with following (bogus) filter:
> tc filter add dev eth0 parent ffff: \
>   protocol ip u32 match u32 0 0 police rate 10Kbit burst \
>   64000 mtu 1500 action reclassify
>
> Signed-off-by: Florian Westphal <fw@strlen.de>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
