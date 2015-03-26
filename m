From: Cong Wang <cwang@twopensource.com>
Subject: Re: [Patch net-next] fib: move fib_rules_cleanup_ops() under rtnl lock
Date: Thu, 26 Mar 2015 15:32:19 -0700
Message-ID: <CAHA+R7Na0BO=rQwFNy-M6pa=TfUXuMDiiwNzsevPpt5CUF=mqQ@mail.gmail.com>
References: <1427403769-31208-1-git-send-email-xiyou.wangcong@gmail.com>
	<55147E5D.2070600@redhat.com>
	<CAHA+R7P4-y4o5WuUwzfwd+LrrkdRdo2=UfXzYdgTrJ63qkaTVg@mail.gmail.com>
	<55148576.1010303@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f176.google.com ([209.85.213.176]:36047 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753355AbbCZWcU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2015 18:32:20 -0400
Received: by igbud6 with SMTP id ud6so5379564igb.1
        for <netdev@vger.kernel.org>; Thu, 26 Mar 2015 15:32:20 -0700 (PDT)
In-Reply-To: <55148576.1010303@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 26, 2015 at 3:17 PM, Alexander Duyck
<alexander.h.duyck@redhat.com> wrote:
>
> On 03/26/2015 02:55 PM, Cong Wang wrote:
>>
>> On Thu, Mar 26, 2015 at 2:47 PM, Alexander Duyck
>> <alexander.h.duyck@redhat.com> wrote:
>>>
>>>
>>> I kind of think the patch title is misleading.  The code was already
>>> under
>>> an rtnl_lock, the problem was it was wrapped in the rules_mod_lock and
>>> that
>>
>>
>> I don't see callers like ipmr_rules_exit() holds a rtnl lock.
>
>
> It doesn't matter since ipmr is using a different set of fib_rules_ops.  So
> for example it doesn't appear to implement a delete so all it is doing is
> dropping the rules.  That is why fib_rules_cleanup_ops needs to stay within
> the rules_mod_lock.

Why ops->delete() matters here since ops->rules_list is generic?

Rules are added to or deleted from ops->rules_list with rtnl lock,
so why it is safe to clean up them all without rtnl lock?

On the other hand, the name rules_mod_lock already tells it is
just a protection for ops (module) register.
