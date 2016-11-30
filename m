From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net-next] audit: remove useless synchronize_net()
Date: Wed, 30 Nov 2016 09:20:04 -0800
Message-ID: <CAM_iQpW1Dt-HKW6fyx_k8E_K8BfAjCqDnw5ud7qVtAWmQ+GviA@mail.gmail.com>
References: <1480439696-21818-1-git-send-email-xiyou.wangcong@gmail.com> <20161130091643.GA32562@madcap2.tricolour.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        linux-audit@redhat.com, Paul Moore <pmoore@redhat.com>
To: Richard Guy Briggs <rgb@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:33676 "EHLO
        mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755100AbcK3RUZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 12:20:25 -0500
Received: by mail-oi0-f68.google.com with SMTP id f201so23946384oib.0
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2016 09:20:25 -0800 (PST)
In-Reply-To: <20161130091643.GA32562@madcap2.tricolour.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 30, 2016 at 1:16 AM, Richard Guy Briggs <rgb@redhat.com> wrote:
> On 2016-11-29 09:14, Cong Wang wrote:
>> netlink kernel socket is protected by refcount, not RCU.
>> Its rcv path is neither protected by RCU. So the synchronize_net()
>> is just pointless.
>
> If I understand correctly, xfrm_user_net_exit() usage of
> RCU_INIT_POINTER() and synchronize_net() is similarly pointless?  Also
> net/phonet/socket.c?  I probably modelled things based on the former...

Possibly, but xfrm case is slightly different, it has two copies of the pointer
to the netlink socket, also it uses exit_batch(). I need to double check.

Take a look at better examples, fib_front, genetlink, rtnetlink.
