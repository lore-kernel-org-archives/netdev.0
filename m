From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next] net: sched: provide stubs for
 tcf_chain_{get,put} for CONFIG_NET_CLS=n
Date: Fri, 19 May 2017 09:50:51 -0700
Message-ID: <CAM_iQpWkoSpWQipShKZP-J-7n79VHa+h5ibbdp0P28mYe7c_GA@mail.gmail.com>
References: <01ab2339375fd161310945aa4eb77c3ecb46b26a.1495124042.git.sd@queasysnail.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Jiri Pirko <jiri@mellanox.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: Sabrina Dubroca <sd@queasysnail.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:35055 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750748AbdESQvR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 May 2017 12:51:17 -0400
Received: by mail-wm0-f67.google.com with SMTP id v4so19411069wmb.2
        for <netdev@vger.kernel.org>; Fri, 19 May 2017 09:51:17 -0700 (PDT)
In-Reply-To: <01ab2339375fd161310945aa4eb77c3ecb46b26a.1495124042.git.sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 18, 2017 at 9:24 AM, Sabrina Dubroca <sd@queasysnail.net> wrote:
> This also changes tcf_chain_get() to return an error pointer instead of
> NULL, so that tcf_action_goto_chain_init() can differentiate memory
> allocation failure from lack of support.
>
> Fixes: 5bc1701881e3 ("net: sched: introduce multichain support for filters")
> Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
> ---
> I'm not sure this EOPNOTSUPP is really necessary, ie if we can really
> reach the tcf_action_goto_chain_init() call when CONFIG_NET_CLS=n.
> If not, a simpler patch would add a tcf_chain_get() stub that just
> returns NULL, as we wouldn't have to care about returning an incorrect
> error code from tcf_action_goto_chain_init().


I wonder if we should just make CONFIG_NET_CLS_ACT depending
on CONFIG_NET_CLS. Although without filters we can still have
standalone actions but no one can use them.
