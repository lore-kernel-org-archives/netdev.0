From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net] act_mirred: avoid calling tcf_hash_release() when binding
Date: Fri, 31 Jul 2015 15:25:02 -0700
Message-ID: <CAM_iQpWmHizNaO7_DhV97APYFpZoApZO3ZzAHu8kv6MopuAg4g@mail.gmail.com>
References: <1438301541-26192-1-git-send-email-xiyou.wangcong@gmail.com>
	<55BB48B8.6060201@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Cong Wang <cwang@twopensource.com>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f179.google.com ([209.85.214.179]:33752 "EHLO
	mail-ob0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752479AbbGaWZE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Jul 2015 18:25:04 -0400
Received: by obdeg2 with SMTP id eg2so63849411obd.0
        for <netdev@vger.kernel.org>; Fri, 31 Jul 2015 15:25:02 -0700 (PDT)
In-Reply-To: <55BB48B8.6060201@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 31, 2015 at 3:06 AM, Daniel Borkmann <daniel@iogearbox.net> wrote:
> Did you test all variants on this?
>
> I.e. what happens when you replace an existing one, I think the
> refcnt should also be dropped here. It looks like we only drop
> it, in case we tried to add an action to an already existing index ...
>

Yeah, clearly the replace case is anti-pattern too, like you showed.

But that is a different bug, right? Since 'bind' is independent of
'replace'. As in $subject, my patch only fixes the binding case.
I will send a following patch to fix replace case.
