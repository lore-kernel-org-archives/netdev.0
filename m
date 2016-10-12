From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [Patch net] net_sched: reorder pernet ops and act ops
 registrations
Date: Wed, 12 Oct 2016 07:29:06 -0400
Message-ID: <d6dc7a72-aa65-e7fb-8ee6-631124233f10@mojatatu.com>
References: <1476208605-16199-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kjlx@templeofstupid.com
To: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f53.google.com ([209.85.214.53]:36970 "EHLO
        mail-it0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932754AbcJLNWM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Oct 2016 09:22:12 -0400
Received: by mail-it0-f53.google.com with SMTP id z65so54840028itc.0
        for <netdev@vger.kernel.org>; Wed, 12 Oct 2016 06:22:11 -0700 (PDT)
In-Reply-To: <1476208605-16199-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-10-11 01:56 PM, Cong Wang wrote:
> Krister reported a kernel NULL pointer dereference after
> tcf_action_init_1() invokes a_o->init(), it is a race condition
> where one thread calling tcf_register_action() to initialize
> the netns data after putting act ops in the global list and
> the other thread searching the list and then calling
> a_o->init(net, ...).
>
> Fix this by moving the pernet ops registration before making
> the action ops visible. This is fine because: a) we don't
> rely on act_base in pernet ops->init(), b) in the worst case we
> have a fully initialized netns but ops is still not ready so
> new actions still can't be created.
>
> Reported-by: Krister Johansen <kjlx@templeofstupid.com>
> Tested-by: Krister Johansen <kjlx@templeofstupid.com>
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>


cheers,
jamal
