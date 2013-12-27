From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] tcp: do not grow receive window if skb->len < 128
Date: Thu, 26 Dec 2013 22:11:08 -0800
Message-ID: <1388124668.12212.51.camel@edumazet-glaptop2.roam.corp.google.com>
References: <2245b9d01fa91d84a8af1e17e1b97f0763f1b792.1388114391.git.panweiping3@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Weiping Pan <panweiping3@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f48.google.com ([209.85.160.48]:41684 "EHLO
	mail-pb0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753358Ab3L0GLK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Dec 2013 01:11:10 -0500
Received: by mail-pb0-f48.google.com with SMTP id md12so8892070pbc.21
        for <netdev@vger.kernel.org>; Thu, 26 Dec 2013 22:11:10 -0800 (PST)
In-Reply-To: <2245b9d01fa91d84a8af1e17e1b97f0763f1b792.1388114391.git.panweiping3@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-12-27 at 11:20 +0800, Weiping Pan wrote:
> Commit 4e4f1fc22681(tcp: properly increase rcv_ssthresh for ofo packets) can
> grow receive window for out of order packets,
> but for in order packets, we only call tcp_grow_window() if skb->len >= 128,
> I think we should add the same condition for out of order packets.
> 

Why do you think so ? Do you have any experimental data to share ?

I personally think the basic test in tcp_event_data_recv() is redundant
with the logic in tcp_grow_window()

skb->len < 128 seems a poor test, real factor is skb->len/skb->truesize
ratio.

Note: Please always CC a patch author when you mention a commit in
a changelog.

Thanks
