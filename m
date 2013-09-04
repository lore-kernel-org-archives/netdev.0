From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Kernel 3.7+ tcp_metric cache system
Date: Wed, 04 Sep 2013 05:34:36 -0700
Message-ID: <1378298076.7360.103.camel@edumazet-glaptop>
References: <CAJWKWvDrjnLpnRR2GmmRLv6EXQdPP9Gb4+-EhWXYhLQzoVrJag@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Simon Jouet <simon.jouet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f52.google.com ([209.85.160.52]:43781 "EHLO
	mail-pb0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756210Ab3IDMei (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Sep 2013 08:34:38 -0400
Received: by mail-pb0-f52.google.com with SMTP id wz12so230244pbc.39
        for <netdev@vger.kernel.org>; Wed, 04 Sep 2013 05:34:38 -0700 (PDT)
In-Reply-To: <CAJWKWvDrjnLpnRR2GmmRLv6EXQdPP9Gb4+-EhWXYhLQzoVrJag@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-09-04 at 13:09 +0100, Simon Jouet wrote:
> Hi,
> 
> First of all apologies if this mailing list doesn't this kind of
> discussions, if not could you please redirect me to a more suitable
> one ?
> 
> So, for my current research I require to be able to specify for
> specific hosts what cwnd and rto to use, after some investigation I
> came accross the modifications that have been done in kernel 3.7 to
> bring the tcp_metric cache and the get/del netlink commands.
> 
> I added a new command "tcp_metrics_nl_cmd_add" to be able to add
> entries to the cache (the code is available here
> http://pastebin.com/gSvhyjWU, this is very much work in progress).
> This work well enough and calling "ip tcpm show" afterwards to list
> the entries show the correct information.
> 
> The issue is that these values are never used or at least from what I
> can see. So once an entry is added it is attempted to be read by the
> function tcp_init_metrics(struct sock *sk) and it's read only if it's
> locked (tcp_metric_locked) I'm not sure what the lock flag is used
> for, f anybody has any pointer for that ...
> 
> Anyway the connection will go to the "reset" goto label, the cwnd will
> be reinitialised by tcp_init_cwnd (defined in tcp_input.c), in what
> I've tested  "__u32 cwnd = (dst ? dst_metric(dst, RTAX_INITCWND) :
> 0);" will always return 0 and the cwnd will be defaulted to 10.
> 
> I'm probably doing something wrong .... But in which condition is the
> cached cwnd used ? I tried to find some documentation on tcp_metric
> but I couldn't find much.
> 

ip ro add 192.168.7.7 via 10.1.10.1 initcwnd 30 rto_min 12
