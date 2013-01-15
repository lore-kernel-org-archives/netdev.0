From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 09/10] bnx2x: Added FW GRO bridging support
Date: Tue, 15 Jan 2013 07:07:47 -0800
Message-ID: <1358262467.8744.5772.camel@edumazet-glaptop>
References: <1358176310-31504-1-git-send-email-yuvalmin@broadcom.com>
	 <1358176310-31504-10-git-send-email-yuvalmin@broadcom.com>
	 <1358184123.8744.3127.camel@edumazet-glaptop>
	 <1358189075.8744.3320.camel@edumazet-glaptop>
	 <50F50537.3030608@broadcom.com>
	 <1358260752.8744.5677.camel@edumazet-glaptop>
	 <50F56178.8000502@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, eilong@broadcom.com,
	ariele@broadcom.com
To: Yuval Mintz <yuvalmin@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:58753 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757312Ab3AOPHu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jan 2013 10:07:50 -0500
Received: by mail-pa0-f42.google.com with SMTP id rl6so153149pac.29
        for <netdev@vger.kernel.org>; Tue, 15 Jan 2013 07:07:50 -0800 (PST)
In-Reply-To: <50F56178.8000502@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-01-15 at 16:02 +0200, Yuval Mintz wrote:
> >>> bnx2x not setting gso_segs means that qdisc accounting on ingress is
> >>> completely wrong.
> >>
> >> Notice this behaviour was not introduced in this patch -
> >>
> >>	...
> >>
> >> We could either:
> >>   1. Continue with this patch, later sending a patch correcting gso_segs,
> >>      as this is not a new issue.
> >>   2. Send a V2 patch-series which will also set gso_segs correctly.
> > 
> > I am fine with any solution, as long as we fix the problem.
> 
> Eric - Thanks.
> Just to be certain - gso_segs should hold the number of non-aggregated packets
> contained in the skb's frags, right?

Thats right

If the FW doesnt provide the info, you could for example do :

shinfo->gso_segs = DIV_ROUND_UP(skb->len - hdr_len, shinfo->gso_size);

(hdr_len being the length of all headers (ethernet+network+TCP))
