From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next] net_sched: fix a regression in tcf_proto_lookup_ops()
Date: Fri, 20 Dec 2013 13:40:27 -0800
Message-ID: <CAM_iQpXk9aJnVOq_LQyk8+cwwqGp=KEqdQ2K32An6BVvdp-SqA@mail.gmail.com>
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
	<CAM_iQpV+WJdeOHOyGENT2XWn=ytjBirBo1G4H2b_QziKHWFw0g@mail.gmail.com>
	<1387570280.19078.461.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f182.google.com ([209.85.214.182]:40605 "EHLO
	mail-ob0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752004Ab3LTVk2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Dec 2013 16:40:28 -0500
Received: by mail-ob0-f182.google.com with SMTP id wp4so3301477obc.41
        for <netdev@vger.kernel.org>; Fri, 20 Dec 2013 13:40:28 -0800 (PST)
In-Reply-To: <1387570280.19078.461.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 20, 2013 at 12:11 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Fri, 2013-12-20 at 11:57 -0800, Cong Wang wrote:
>
>> Then why mirred_cleanup_module() appears in the top of your backtrace?
>
> Because you have not understood the trace ?
>
> Thats exactly why its not useful at all.
>
>
> [   76.656061] RIP: 0010:[<ffffffffa008d882>]  [<ffffffffa008d882>] mirred_cleanup_module+0x13a/0x2a [act_mirred]^M
>
>
> This means RIP is _after_ mirred_cleanup_module() body, as this function size if 0x2a bytes
>
> We were trying to execute a data portion which happens to be in
> the neighboring of innocent mirred_cleanup_module()
>
> When not using module, trace was different and made no sense anyway :
>
...
>
> We actually try to execute code at ffffffff818a4b80 == &act_mirred_ops
>
> ffffffff818a4b40 d cls_mod_lock
> ffffffff818a4b50 d tcf_proto_base
> ffffffff818a4b60 d act_mod_lock
> ffffffff818a4b70 d act_base
> ffffffff818a4b80 d act_mirred_ops
> ffffffff818a4bf0 d mirred_device_notifier
> ffffffff818a4c10 d mirred_list
> ffffffff818a4c20 d _rs.42828
> ffffffff818a4c40 d ematch_mod_lock
> ffffffff818a4c50 d ematch_ops
>
> So only a bisection actually gave me the faulty commit.
>
> Stacktrace was absolutely useless.
>
>

Thanks for explaining this. Then:

Reviewed-by: Cong Wang <xiyou.wangcong@gmail.com>
