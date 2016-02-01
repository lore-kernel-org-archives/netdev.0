From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] route: add rcu_read_lock when lookup route and
 update fnhe in __ip_do_redirect
Date: Mon, 01 Feb 2016 05:46:47 -0800
Message-ID: <1454334407.7627.163.camel@edumazet-glaptop2.roam.corp.google.com>
References: <db60649416c596fc5e76930484b726cb180b14b8.1454322132.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: network dev <netdev@vger.kernel.org>, davem@davemloft.net,
	hannes@stressinduktion.org
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:36528 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932183AbcBANqu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Feb 2016 08:46:50 -0500
Received: by mail-pa0-f44.google.com with SMTP id yy13so82403260pab.3
        for <netdev@vger.kernel.org>; Mon, 01 Feb 2016 05:46:49 -0800 (PST)
In-Reply-To: <db60649416c596fc5e76930484b726cb180b14b8.1454322132.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-02-01 at 18:22 +0800, Xin Long wrote:

> But there may be an issue in __ip_do_redirect():
>          } else {
>              if (fib_lookup(net, fl4, &res, 0) == 0) {
>                  struct fib_nh *nh = &FIB_RES_NH(res);
> 
>                  update_or_create_fnhe(nh, fl4->daddr, new_gw,
>                                0, 0);
>              }
> 
> Which is not running in rcu_read_lock(), it may update a fnhe that
> has been freed.
> 
> So fix it by adding rcu_read_lock() just like other parts.

But the whole __ip_do_redirect() needs to be called from rcu_read_lock()
already.

No need to add another rcu_read_lock() around fib_lookup()

How did you come doing this patch ? Any particular stack dump or
something ?
