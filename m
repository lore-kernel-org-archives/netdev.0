From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net v2 2/2] net_sched: fix all the madness of tc filter chain
Date: Fri, 8 Sep 2017 09:37:55 -0700
Message-ID: <CAM_iQpUJLfkq0ys3XNchPVXBpF4yoNaBG_L7UjiSMW7_9NyYaQ@mail.gmail.com>
References: <20170907042607.24413-1-xiyou.wangcong@gmail.com>
 <20170907042607.24413-2-xiyou.wangcong@gmail.com> <20170907063216.GB1967@nanopsycho>
 <CAM_iQpXsYc1cfZmuFKGH1O-FPJr9+NJqZTTB5z1oJVGYgvkV+Q@mail.gmail.com> <20170907205239.GF1967@nanopsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Jakub Kicinski <jakub.kicinski@netronome.com>,
        Jiri Pirko <jiri@mellanox.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f42.google.com ([74.125.83.42]:35409 "EHLO
        mail-pg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756435AbdIHQiR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 8 Sep 2017 12:38:17 -0400
Received: by mail-pg0-f42.google.com with SMTP id 188so5681074pgb.2
        for <netdev@vger.kernel.org>; Fri, 08 Sep 2017 09:38:16 -0700 (PDT)
In-Reply-To: <20170907205239.GF1967@nanopsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 7, 2017 at 1:52 PM, Jiri Pirko <jiri@resnulli.us> wrote:
> Thu, Sep 07, 2017 at 07:45:49PM CEST, xiyou.wangcong@gmail.com wrote:
>>Yes it is for chain 0, because block holds a reference to chain 0 during
>>creation. Non-0 chains are created with refcnt==1 too but paired with
>>tcf_chain_put() rather than tcf_block_put(). This is what makes chain 0
>>not special w.r.t. refcnt.
>
> So you need to tcf_chain_put only chain 0 here, right? The rest of the
> chains get destroyed by the previous list_for_each_entry iteration when
> flush happens and actions destroy happens what decrements recnt to 0
> there.


This is correct. And it should be only chain 0 after flush.

>
> What do I miss, who would still hold reference for non-0 chains when all
> tps and all goto_chain actions are gone?

No one. This is totally correct and is exactly what this patch intends to do.

Look, this is why we never need an object with refcnt==0 to exist. ;)
