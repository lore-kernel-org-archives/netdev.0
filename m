From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next v4 3/8] net_sched: mirred: remove action when the
 target device is gone
Date: Wed, 18 Dec 2013 10:36:06 -0800
Message-ID: <CAM_iQpUDZa-=H53Csg8476xOL0xP+rn85O8eB1O39-eF_Jo+uw@mail.gmail.com>
References: <1387167311-14763-1-git-send-email-xiyou.wangcong@gmail.com>
	<1387167311-14763-4-git-send-email-xiyou.wangcong@gmail.com>
	<52B1B1B1.2060501@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f45.google.com ([209.85.219.45]:38291 "EHLO
	mail-oa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753427Ab3LRSgH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 13:36:07 -0500
Received: by mail-oa0-f45.google.com with SMTP id o6so38361oag.32
        for <netdev@vger.kernel.org>; Wed, 18 Dec 2013 10:36:07 -0800 (PST)
In-Reply-To: <52B1B1B1.2060501@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 18, 2013 at 6:31 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> On 12/15/13 23:15, Cong Wang wrote:
>>
>> When the target device is removed, the mirred action is
>> still there but with the dev pointer setting to NULL.
>> This makes the output from 'tc filter' ugly. There is no
>> reason to keep it.
>>
>
> Sorry - this one i have problems with.
> actions may be referenced from multiple filters,
> you cant just delete it (that would leave other users
> pointing to it dangling). Destroying would eventually
> delete it when the refcount goes to 0.

How? tcf_action_init() always allocates a new action,
it doesn't even look for an existing one.

> [And when we delete actions we send netlink events to announce
> that]. The proper solution would require i.e tag it as to be
> deleted and implement some form of garbage collection.

It doesn't worth to have a GC for this...

Even if what you said is true, we should just make a copy
for each of the filters. I just tried to create two different filters
with same and different mirred actions, my patch works
perfectly.
