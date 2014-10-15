From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] ipv4: dst_entry leak in ip_append_data()
Date: Tue, 14 Oct 2014 21:46:25 -0700
Message-ID: <1413348385.12304.0.camel@edumazet-glaptop2.roam.corp.google.com>
References: <543CAD2A.3070701@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Vasily Averin <vvs@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:38557 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750736AbaJOEq0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Oct 2014 00:46:26 -0400
Received: by mail-pd0-f173.google.com with SMTP id g10so556139pdj.4
        for <netdev@vger.kernel.org>; Tue, 14 Oct 2014 21:46:26 -0700 (PDT)
In-Reply-To: <543CAD2A.3070701@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-10-14 at 08:57 +0400, Vasily Averin wrote:
> v2: adjust the indentation of the arguments __ip_append_data() call
> 
> Fixes: 2e77d89b2fa8 ("net: avoid a pair of dst_hold()/dst_release() in ip_append_data()")
> 
> If sk_write_queue is empty ip_append_data() executes ip_setup_cork()
> that "steals" dst entry from rt to cork. Later it calls __ip_append_data()
> that creates skb and adds it to sk_write_queue.
> 
> If skb was added successfully following ip_push_pending_frames() call
> reassign dst entries from cork to skb, and kfree_skb frees dst_entry.
> 
> However nobody frees stolen dst_entry if skb was not added into sk_write_queue.

I thought this was done by ip_flush_pending_frames() ?

Can you describe the issue more precisely ?

Thanks !
