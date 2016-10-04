From: Krister Johansen <kjlx@templeofstupid.com>
Subject: Re: [PATCH net] Panic when tc_lookup_action_n finds a partially
 initialized action.
Date: Mon, 3 Oct 2016 23:38:51 -0700
Message-ID: <20161004063851.GA2638@templeofstupid.com>
References: <20161002031349.GB2635@templeofstupid.com>
 <92102cf9-9f27-3a9f-06b6-f45201dbc55c@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Krister Johansen <kjlx@templeofstupid.com>, netdev@vger.kernel.org,
        Cong Wang <xiyou.wangcong@gmail.com>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hapkido.dreamhost.com ([66.33.216.122]:43565 "EHLO
        hapkido.dreamhost.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751764AbcJDGiz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Oct 2016 02:38:55 -0400
Received: from homiemail-a81.g.dreamhost.com (sub5.mail.dreamhost.com [208.113.200.129])
        by hapkido.dreamhost.com (Postfix) with ESMTP id 38FE0E97F3
        for <netdev@vger.kernel.org>; Mon,  3 Oct 2016 23:38:54 -0700 (PDT)
Received: from homiemail-a81.g.dreamhost.com (localhost [127.0.0.1])
        by homiemail-a81.g.dreamhost.com (Postfix) with ESMTP id 3CC3D5A2F
        for <netdev@vger.kernel.org>; Mon,  3 Oct 2016 23:38:53 -0700 (PDT)
Received: from kmjvbox (c-73-202-117-160.hsd1.ca.comcast.net [73.202.117.160])
        (using TLSv1 with cipher ECDHE-RSA-AES256-SHA (256/256 bits))
        (No client certificate requested)
        (Authenticated sender: kjlx@templeofstupid.com)
        by homiemail-a81.g.dreamhost.com (Postfix) with ESMTPSA id 194635A27
        for <netdev@vger.kernel.org>; Mon,  3 Oct 2016 23:38:53 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <92102cf9-9f27-3a9f-06b6-f45201dbc55c@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 02, 2016 at 09:18:06PM -0400, Jamal Hadi Salim wrote:
> On 16-10-01 11:13 PM, Krister Johansen wrote:
> >A tc_action_ops structure is visibile as soon as it is placed in the
> >act_base list.  When tcf_regsiter_action adds an item to this list and
> >drops act_mod_lock, registration is not complete until
> >register_pernet_subsys() finishes.
> >
> >If two threads attempt to modify a tc action in a way that triggers a
> >module load, the thread that wins the race ends up defeferencing a NULL
> >pointer after tcf_action_init_1() invokes a_o->init().  In the
> >particular case that this submitter encountered, the panic occurred in
> >tcf_gact_init() when net_generic() returned a NULL tc_action_net
> >pointer.  The gact_net_id needed to fetch the correct pointer was not
> >yet set, because the register_pernet_subsys() call was pending in
> >another thread.
> >
> >Fixes: ddf97ccdd7cb ("net_sched: add network namespace support for tc actions")
> >Signed-off-by: Krister Johansen <kjlx@templeofstupid.com>
> 
> Looks reasonable to me but will let Cong a closer look since he added
> that code.

Thanks, I appreicate you taking a look.  I'll follow up with Cong.

-K
