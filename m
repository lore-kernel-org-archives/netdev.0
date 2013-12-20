From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next] net_sched: fix a regression in tcf_proto_lookup_ops()
Date: Fri, 20 Dec 2013 11:57:25 -0800
Message-ID: <CAM_iQpV+WJdeOHOyGENT2XWn=ytjBirBo1G4H2b_QziKHWFw0g@mail.gmail.com>
References: <1387526931-21814-1-git-send-email-xiyou.wangcong@gmail.com>
	<52B434FA.8080309@mojatatu.com>
	<1387550222.19078.434.camel@edumazet-glaptop2.roam.corp.google.com>
	<52B45851.90208@mojatatu.com>
	<1387555659.19078.439.camel@edumazet-glaptop2.roam.corp.google.com>
	<1387560028.19078.442.camel@edumazet-glaptop2.roam.corp.google.com>
	<1387560578.19078.443.camel@edumazet-glaptop2.roam.corp.google.com>
	<1387562658.19078.448.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAM_iQpUQ3iaq+X+CngqJCGWq5Ep_XhcfWEKqrCQcZ3iC6Uz_qA@mail.gmail.com>
	<1387568188.19078.453.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f49.google.com ([209.85.219.49]:40427 "EHLO
	mail-oa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750866Ab3LTT50 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Dec 2013 14:57:26 -0500
Received: by mail-oa0-f49.google.com with SMTP id i4so3306111oah.8
        for <netdev@vger.kernel.org>; Fri, 20 Dec 2013 11:57:25 -0800 (PST)
In-Reply-To: <1387568188.19078.453.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 20, 2013 at 11:36 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Fri, 2013-12-20 at 11:11 -0800, Cong Wang wrote:
>> On Fri, Dec 20, 2013 at 10:04 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> > From: Eric Dumazet <edumazet@google.com>
>> >
>> > list_for_each_entry(t, &tcf_proto_base, head) doesn't
>> > exit with t = NULL if we reached the end of the list.
>> >
>> > Signed-off-by: Eric Dumazet <edumazet@google.com>
>> > Fixes: 3627287463b4 ("net_sched: convert tcf_proto_ops to use struct
>> > list_head")
>> > Cc: Cong Wang <xiyou.wangcong@gmail.com>
>> > ---
>> >  net/sched/cls_api.c |   22 ++++++++++------------
>> >  1 file changed, 10 insertions(+), 12 deletions(-)
>>
>> The bug you reported to me yesterday is in mirred action module cleanup,
>> so how is it possible to be fixed in cls_api.c? It should be act_api.c.
>>
>> If you meant to fix a different bug, please include the backtrace in the log?
>
> Why ?
>
> I think the bug is obvious and do not need a verbose stack trace in the
> changelog.
>
> Even you were not able to decrypt it, as you thought it was a bug in
> mirred code. You keep saying it was cause by module cleanup, while
> I already said the module was not removed at all.

Then why mirred_cleanup_module() appears in the top of your backtrace?

>
>>
>> Your patch looks good generally, but actually I doubt we need to check for
>> an existing ops when unregistering, since we almost for sure only unregister
>> existing ones as they are all static allocated.
>
> Well, lets fix the bug first. I do not think there is any point trying
> to be smart in this slow path. Particularly if I have to spend 2 more
> hours to fix some random bug.
>
>

The current code is smarter actually. Sure, please fix act_api.c as well?
