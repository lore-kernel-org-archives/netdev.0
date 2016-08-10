From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [Patch net 0/5] net_sched: tc action fixes and updates
Date: Wed, 10 Aug 2016 09:54:31 -0400
Message-ID: <ee17984e-35ec-3331-9143-4e00c06f21c9@mojatatu.com>
References: <1470689209-17682-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:35251 "EHLO
	mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932794AbcHJSH7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Aug 2016 14:07:59 -0400
Received: by mail-pf0-f170.google.com with SMTP id x72so18195279pfd.2
        for <netdev@vger.kernel.org>; Wed, 10 Aug 2016 11:07:59 -0700 (PDT)
In-Reply-To: <1470689209-17682-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-08-08 04:46 PM, Cong Wang wrote:
> This patchset fixes several regressions caused by the previous
> code refactor. Thanks to Jamal for catching them!
>
> Note, patch 3/5 and 4/5 are not strictly necessary, I just
> want to carry them together.


Cong - there's good news and bad news.
The good news is that the oopses are fixed.
The bad news is you have now slowed down the system. It is noticeable
at high speed.
I narrowed it down to your use of flex arrays. In particular
tcf_exts_exec() call:
This is the fast path - was flexarray really necessary?
The conversion to list is slowing things down.

As hard as this is for me to say:
I am actually beginning to question this whole patch series.
Either you have a plan to fix this regression or lets just
pull this out for now to regain stability until we get our
act together. I think it would make a lot of sense to just pass
an array instead of a list.

cheers,
jamal
