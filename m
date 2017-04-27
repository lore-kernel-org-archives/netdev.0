From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net-next] ipv4: get rid of ip_ra_lock
Date: Thu, 27 Apr 2017 16:46:25 -0700
Message-ID: <CAM_iQpXexP9OzzqyPJ-yHmyq-ZF=cNboaG8566yaxZKbn0+TTg@mail.gmail.com>
References: <1493240115-779-1-git-send-email-xiyou.wangcong@gmail.com> <1493297179.6453.105.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:33833 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754271AbdD0Xqq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2017 19:46:46 -0400
Received: by mail-wm0-f66.google.com with SMTP id z129so7811275wmb.1
        for <netdev@vger.kernel.org>; Thu, 27 Apr 2017 16:46:46 -0700 (PDT)
In-Reply-To: <1493297179.6453.105.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 27, 2017 at 5:46 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Wed, 2017-04-26 at 13:55 -0700, Cong Wang wrote:
>> After commit 1215e51edad1 ("ipv4: fix a deadlock in ip_ra_control")
>> we always take RTNL lock for ip_ra_control() which is the only place
>> we update the list ip_ra_chain, so the ip_ra_lock is no longer needed,
>> we just need to disable BH there.
>>
>> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
>> ---
>
> Looks great, but reading again this code, I believe we do not need to
> disable BH at all ?
>

Hmm, if we don't disable BH here, a reader in BH could jump in and
break this critical section? Or that is fine for RCU?
