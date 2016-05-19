From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC net-next] net: sched: do not acquire qdisc spinlock in
 qdisc/class stats dump
Date: Thu, 19 May 2016 10:02:19 -0700
Message-ID: <1463677339.18194.197.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1463661320.18194.178.camel@edumazet-glaptop3.roam.corp.google.com>
	 <20160519160803.GA70549@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	John Fastabend <john.fastabend@gmail.com>,
	Kevin Athey <kda@google.com>,
	Xiaotian Pei <xiaotian@google.com>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f67.google.com ([209.85.220.67]:36656 "EHLO
	mail-pa0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754321AbcESRC2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 May 2016 13:02:28 -0400
Received: by mail-pa0-f67.google.com with SMTP id xm6so8402404pab.3
        for <netdev@vger.kernel.org>; Thu, 19 May 2016 10:02:28 -0700 (PDT)
In-Reply-To: <20160519160803.GA70549@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-05-19 at 09:08 -0700, Alexei Starovoitov wrote:

> initially I thought that above line could have been qdisc_root_sleeping_lock()
> but then realized that moving out ASSERT_RTNL makes more sense. Good call.
> The only thing not clear to me is why '!defined(CONFIG_LOCKDEP)' ?
> Just extra caution? I think should be fine without it.

I believe it is better to exercise this code path (using spinlock) even
on 64bit kernel for kernels with LOCKDEP.

This could avoid some hard to debug bugs occurring on 32bit builds.
