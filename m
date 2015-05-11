From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH -next] net: sched: use counter to break reclassify loops
Date: Mon, 11 May 2015 13:30:07 -0700
Message-ID: <20150511203006.GA2914@Alexeis-MacBook-Pro.local>
References: <1431366641-24735-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jhs@mojatatu.com
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:34748 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752628AbbEKUaL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 May 2015 16:30:11 -0400
Received: by pdbqa5 with SMTP id qa5so152649847pdb.1
        for <netdev@vger.kernel.org>; Mon, 11 May 2015 13:30:10 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1431366641-24735-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 11, 2015 at 07:50:41PM +0200, Florian Westphal wrote:
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
>  protocol ip u32 match u32 0 0 police rate 10Kbit burst \
>  64000 mtu 1500 action reclassify
> 
> Acked-by: Daniel Borkmann <daniel@iogearbox.net>
> Signed-off-by: Florian Westphal <fw@strlen.de>

agree. that's my reading of the code as well.
Acked-by: Alexei Starovoitov <ast@plumgrid.com>
