From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net] Panic when tc_lookup_action_n finds a partially
 initialized action.
Date: Sun, 2 Oct 2016 21:18:06 -0400
Message-ID: <92102cf9-9f27-3a9f-06b6-f45201dbc55c@mojatatu.com>
References: <20161002031349.GB2635@templeofstupid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Cong Wang <xiyou.wangcong@gmail.com>
To: Krister Johansen <kjlx@templeofstupid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:35480 "EHLO
        mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751873AbcJCBTW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 2 Oct 2016 21:19:22 -0400
Received: by mail-pa0-f68.google.com with SMTP id t6so4119204pae.2
        for <netdev@vger.kernel.org>; Sun, 02 Oct 2016 18:19:21 -0700 (PDT)
In-Reply-To: <20161002031349.GB2635@templeofstupid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-10-01 11:13 PM, Krister Johansen wrote:
> A tc_action_ops structure is visibile as soon as it is placed in the
> act_base list.  When tcf_regsiter_action adds an item to this list and
> drops act_mod_lock, registration is not complete until
> register_pernet_subsys() finishes.
>
> If two threads attempt to modify a tc action in a way that triggers a
> module load, the thread that wins the race ends up defeferencing a NULL
> pointer after tcf_action_init_1() invokes a_o->init().  In the
> particular case that this submitter encountered, the panic occurred in
> tcf_gact_init() when net_generic() returned a NULL tc_action_net
> pointer.  The gact_net_id needed to fetch the correct pointer was not
> yet set, because the register_pernet_subsys() call was pending in
> another thread.
>
> Fixes: ddf97ccdd7cb ("net_sched: add network namespace support for tc actions")
> Signed-off-by: Krister Johansen <kjlx@templeofstupid.com>

Looks reasonable to me but will let Cong a closer look since he added
that code.

cheers,
jamal
