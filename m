From: Simon Jouet <simon.jouet@gmail.com>
Subject: Kernel 3.7+ tcp_metric cache system
Date: Wed, 4 Sep 2013 13:09:05 +0100
Message-ID: <CAJWKWvDrjnLpnRR2GmmRLv6EXQdPP9Gb4+-EhWXYhLQzoVrJag@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f47.google.com ([209.85.215.47]:42727 "EHLO
	mail-la0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932464Ab3IDMJG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Sep 2013 08:09:06 -0400
Received: by mail-la0-f47.google.com with SMTP id eo20so190316lab.34
        for <netdev@vger.kernel.org>; Wed, 04 Sep 2013 05:09:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

First of all apologies if this mailing list doesn't this kind of
discussions, if not could you please redirect me to a more suitable
one ?

So, for my current research I require to be able to specify for
specific hosts what cwnd and rto to use, after some investigation I
came accross the modifications that have been done in kernel 3.7 to
bring the tcp_metric cache and the get/del netlink commands.

I added a new command "tcp_metrics_nl_cmd_add" to be able to add
entries to the cache (the code is available here
http://pastebin.com/gSvhyjWU, this is very much work in progress).
This work well enough and calling "ip tcpm show" afterwards to list
the entries show the correct information.

The issue is that these values are never used or at least from what I
can see. So once an entry is added it is attempted to be read by the
function tcp_init_metrics(struct sock *sk) and it's read only if it's
locked (tcp_metric_locked) I'm not sure what the lock flag is used
for, f anybody has any pointer for that ...

Anyway the connection will go to the "reset" goto label, the cwnd will
be reinitialised by tcp_init_cwnd (defined in tcp_input.c), in what
I've tested  "__u32 cwnd = (dst ? dst_metric(dst, RTAX_INITCWND) :
0);" will always return 0 and the cwnd will be defaulted to 10.

I'm probably doing something wrong .... But in which condition is the
cached cwnd used ? I tried to find some documentation on tcp_metric
but I couldn't find much.

Best regards,
Simon

P.S : If anything is unclear please let me know, so I can rephrase or
provide more details
