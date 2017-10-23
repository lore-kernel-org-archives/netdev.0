From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] tcp/dccp: fix again lockdep splat in
 inet_csk_route_req()
Date: Mon, 23 Oct 2017 15:46:46 -0700
Message-ID: <1508798806.30291.94.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20171023095634.lednbqrxtbuooqcx@inn>
         <1508770960.30291.83.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: kernel test robot <fengguang.wu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f179.google.com ([209.85.223.179]:55531 "EHLO
        mail-io0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751290AbdJWWqt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Oct 2017 18:46:49 -0400
Received: by mail-io0-f179.google.com with SMTP id p186so21823707ioe.12
        for <netdev@vger.kernel.org>; Mon, 23 Oct 2017 15:46:49 -0700 (PDT)
In-Reply-To: <1508770960.30291.83.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-10-23 at 08:02 -0700, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> In my first attempt to fix the lockdep splat, I forgot we could
> enter inet_csk_route_req() with a freshly allocated request socket,
> for which refcount has not yet been elevated, due to complex
> SLAB_TYPESAFE_BY_RCU rules.
> 
> We either are in rcu_read_lock() section _or_ we own a refcount on the
> request.
> 
> Correct RCU verb to use here is rcu_dereference_check(), although it is
> not possible to prove we actually own a reference on a shared
> refcount :/


David, please hold on this patch, I will squash another fixes, since we
need the same in two other places (tcp_v4_send_synack() &
dccp_v4_send_response())
