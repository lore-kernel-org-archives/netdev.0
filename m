From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH 0/2] net_sched: Remove broken tc actions
Date: Sun, 27 Oct 2013 12:58:38 -0400
Message-ID: <526D463E.6040000@mojatatu.com>
References: <87fvrmu909.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexander.h.duyck@intel.com
To: "Eric W. Biederman" <ebiederm@xmission.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f176.google.com ([209.85.223.176]:37041 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753482Ab3J0Q6t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Oct 2013 12:58:49 -0400
Received: by mail-ie0-f176.google.com with SMTP id u16so9357386iet.7
        for <netdev@vger.kernel.org>; Sun, 27 Oct 2013 09:58:48 -0700 (PDT)
In-Reply-To: <87fvrmu909.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/27/13 09:40, Eric W. Biederman wrote:
>
> While auditing the code to make certain it would be safe to enable the
> user namespace root to use tc actions I stumbled on the strange fact
> that two of the tc modules in the kernel have been broken for more
> years than I care to think about.
>
> In particular neither of these two modules implements the tc_action_ops
> lookup method.  Which means that in practice neither RTM_GETACTION nor
> RTM_DELACTION work.  And with RTM_DELACTION broken that looks like a
> permanent leak of kernel memory to me.
>
 >
> A leak I am not happy at root having and certainly not something I want
> to allow unprivileged users access to.
>
> On the premise that 5+ years is too long to wait for someone to notice,
> complain and get this code fixed let's just remove these broken tc
> modules.
>


Nah, dude.
You dont have to implement the get/del. Actions are typically bound
to filters; when the filters disappears the action is destroyed.
You Get the filter, you Get the bound actions.
you can add actions without filters - but in such a case, for both
of these ones you picked, you can dump or flush them unless they are
bound to a filter. Thats the minimal requirement (which is met).

What is your use case to need explicit get/del?
Given act_simple is pedagogical in nature, I think
that will be useful for illustration purposes.

cheers,
jamal
