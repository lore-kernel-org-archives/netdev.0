From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] bgmac: add support for Byte Queue Limits
Date: Sat, 28 Sep 2013 16:22:16 -0700
Message-ID: <1380410536.3596.11.camel@edumazet-glaptop.roam.corp.google.com>
References: <1380407726-20691-1-git-send-email-hauke@hauke-m.de>
	 <1380409400.3596.9.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, zajec5@gmail.com, netdev@vger.kernel.org
To: Hauke Mehrtens <hauke@hauke-m.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f49.google.com ([209.85.160.49]:48892 "EHLO
	mail-pb0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755184Ab3I1XWS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Sep 2013 19:22:18 -0400
Received: by mail-pb0-f49.google.com with SMTP id xb4so3970914pbc.8
        for <netdev@vger.kernel.org>; Sat, 28 Sep 2013 16:22:17 -0700 (PDT)
In-Reply-To: <1380409400.3596.9.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2013-09-28 at 16:03 -0700, Eric Dumazet wrote:

> Unfortunately, skb->len is unsafe : hardware might already sent the
> packet and TX completion have freed it.
> 
> You must cache skb->len in a variable before allowing hardware to send
> the frame.
> 

More exactly you must call netdev_sent_queue() _before_ giving skb to
hardware, or netdev_completed_queue() might panic.
