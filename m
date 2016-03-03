From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH RFC] net: Fix race condition when removing qdisc
Date: Thu, 3 Mar 2016 15:58:15 -0800
Message-ID: <CALx6S34tWHZQJfTCc6vDkgDbo1DDFP33LNFnMJ591QEW87YAmA@mail.gmail.com>
References: <1456874197-3036009-1-git-send-email-tom@herbertland.com>
	<CAM_iQpWxkd16A_=htGxjA6OVBj_kzBZKsOF-JmsQQLbJc=r_WA@mail.gmail.com>
	<CALx6S36-LNu_uqPP3is1U7gO48qtbkTADgxpm_ecuHN+UuxrgQ@mail.gmail.com>
	<1457049168.2761.3.camel@edumazet-ThinkPad-T530>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Lawrence Brakmo <brakmo@fb.com>,
	Kernel Team <kernel-team@fb.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f196.google.com ([209.85.213.196]:35479 "EHLO
	mail-ig0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755871AbcCCX6Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2016 18:58:16 -0500
Received: by mail-ig0-f196.google.com with SMTP id ww10so803060igb.2
        for <netdev@vger.kernel.org>; Thu, 03 Mar 2016 15:58:16 -0800 (PST)
In-Reply-To: <1457049168.2761.3.camel@edumazet-ThinkPad-T530>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 3, 2016 at 3:52 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On jeu., 2016-03-03 at 14:24 -0800, Tom Herbert wrote:
>> This a kernel based on 3.10. We believe the lockups coincide with
>> removing/readding qdiscs.
>
> You could backport 64153ce0a7b61b2a
> ("net_sched: htb: do not setup default rate estimators"),
> unless you desperately want these rate estimators...
>
> How many HTB classes do you deal with ?
>
~1500.

One think that looks odd to me is that htb_destroy_class is not doing
an rcu_free (just kfree(cl)). I'm thinking that est_timer can run
after that kfree and be accessing some of the fields in the freed
structure (at least rate_est).

Tom
