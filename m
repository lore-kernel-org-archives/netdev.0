From: Cong Wang <cwang@twopensource.com>
Subject: Re: [Patch net-next] fib: move fib_rules_cleanup_ops() under rtnl lock
Date: Thu, 26 Mar 2015 16:05:44 -0700
Message-ID: <CAHA+R7MKNcOOiAsV7iQ2WT=sXCmaM0FuJ0OuY_S8reP2K8hN=w@mail.gmail.com>
References: <1427403769-31208-1-git-send-email-xiyou.wangcong@gmail.com>
	<55147E5D.2070600@redhat.com>
	<CAHA+R7P4-y4o5WuUwzfwd+LrrkdRdo2=UfXzYdgTrJ63qkaTVg@mail.gmail.com>
	<55148576.1010303@redhat.com>
	<CAHA+R7Na0BO=rQwFNy-M6pa=TfUXuMDiiwNzsevPpt5CUF=mqQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f176.google.com ([209.85.213.176]:34890 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751900AbbCZXFo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2015 19:05:44 -0400
Received: by igcau2 with SMTP id au2so6055111igc.0
        for <netdev@vger.kernel.org>; Thu, 26 Mar 2015 16:05:44 -0700 (PDT)
In-Reply-To: <CAHA+R7Na0BO=rQwFNy-M6pa=TfUXuMDiiwNzsevPpt5CUF=mqQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 26, 2015 at 3:32 PM, Cong Wang <cwang@twopensource.com> wrote:
>
> On the other hand, the name rules_mod_lock already tells it is
> just a protection for ops (module) register.

I even doubt we really need rules_mod_lock, it is per netns,
which is newly allocated when registering pernet and upper
layer should guarantee no concurrent unregistering, so we
probably only need to take rtnl lock.
