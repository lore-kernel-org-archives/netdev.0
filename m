From: Cong Wang <cwang@twopensource.com>
Subject: Re: [Patch net-next] net_sched: avoid calling tcf_unbind_filter() in
 call_rcu callback
Date: Wed, 1 Oct 2014 16:36:57 -0700
Message-ID: <CAHA+R7O6cHL2csRKxsyggR+qJfLgHgf+hE4MXQakf72zLN6mOw@mail.gmail.com>
References: <1412118444-29179-1-git-send-email-xiyou.wangcong@gmail.com>
	<1412118444-29179-2-git-send-email-xiyou.wangcong@gmail.com>
	<542B5096.2040106@gmail.com>
	<542B5679.3060601@gmail.com>
	<542C6910.4070904@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: John Fastabend <john.fastabend@gmail.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f172.google.com ([209.85.217.172]:62705 "EHLO
	mail-lb0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751798AbaJAXg6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2014 19:36:58 -0400
Received: by mail-lb0-f172.google.com with SMTP id b6so1287962lbj.31
        for <netdev@vger.kernel.org>; Wed, 01 Oct 2014 16:36:57 -0700 (PDT)
In-Reply-To: <542C6910.4070904@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 1, 2014 at 1:50 PM, John Fastabend
<john.r.fastabend@intel.com> wrote:
>
> Its worth noting why this is safe. Any running schedulers will either
> read the valid class field or it will be zeroed.
>
> All schedulers today when the class is 0 do a lookup using the
> same call used by the tcf_exts_bind(). So even if we have a running
> classifier hit the null class pointer it will do a lookup and get
> to the same result. This is particularly fragile at the moment because
> the only way to verify this is to audit the schedulers call sites.

Yeah, maybe David can squash this into changelog.

>
> I think we need a helper to ensure the code doesn't get broken in
> a subtle way in the future. At very least it should be documented.
> I'll try to draft a follow up patch to use a helper routine for
> this and document it.
>
> Similar patches are needed for basic, fw, route, rsvp, and tcindex.
>

Please do fix them. Meanwhile, I am trying to refactor these pieces
of ugly code.

Thanks.
