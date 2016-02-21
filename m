From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net] net_sched: fix memory leaks when rmmod tc action modules
Date: Sat, 20 Feb 2016 16:27:07 -0800
Message-ID: <CAM_iQpXb6ngsdRDo3QpzTis22rdhPwBkv33BPG9WyBffdbTC5A@mail.gmail.com>
References: <1455926779-9379-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f178.google.com ([209.85.161.178]:34376 "EHLO
	mail-yw0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751105AbcBUA1I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Feb 2016 19:27:08 -0500
Received: by mail-yw0-f178.google.com with SMTP id h129so94485940ywb.1
        for <netdev@vger.kernel.org>; Sat, 20 Feb 2016 16:27:07 -0800 (PST)
In-Reply-To: <1455926779-9379-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 19, 2016 at 4:06 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> We only release the memory of the hashtable itself, not its
> entries inside. We need to do both.
>
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Hmm, after a second thought, actually each action should take
a reference to its module, therefore module will not be removed
until all the actions are gone, so no leak here.

The reason why I saw a leak is tcf_hashinfo_destroy() is called
in netns cleanup in the other patch.

So, this patch should be targeted for net-next only. I will resend it
with an updated changelog with the other patch.

Sorry for the confusion.
