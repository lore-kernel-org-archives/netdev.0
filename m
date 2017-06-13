From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH nf-next] netns: add and use net_ns_barrier
Date: Tue, 13 Jun 2017 14:16:28 -0700
Message-ID: <CAM_iQpXiHOarvPHweT+=bRmztU0VeNQhUgHw7B7qbwndJ0NBUg@mail.gmail.com>
References: <20170530093812.10712-1-fw@strlen.de> <87y3tcj3n7.fsf@xmission.com>
 <20170601085259.GA6067@breakpoint.cc> <CAM_iQpXgrQcbrQsMVoomcsHtk4JffRjJ27FLRoignndAzFVkug@mail.gmail.com>
 <20170613061656.GF18283@breakpoint.cc> <CAM_iQpUtZZBXQNB+tWJikQNmCHBot3tp7vAsc6+Xnh5H__6++g@mail.gmail.com>
 <20170613180713.GA10130@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
        netfilter-devel@vger.kernel.org,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:35856 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752326AbdFMVQu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Jun 2017 17:16:50 -0400
In-Reply-To: <20170613180713.GA10130@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 13, 2017 at 11:07 AM, Florian Westphal <fw@strlen.de> wrote:
> Historically it wasn't needed because we just clear out the helper area
> in the affected conntracks (i.e, future packets are not inspected by
> the helper anymore).
>
> When conntracks were made per-netns this problem was added as we're not
> guaranteed to see all net namespace because module_exit and netns cleanup
> can run concurrently.
>
> We can still use the "old" model if we guarantee that we wait for
> netns cleanup to finish (which is what this patch does).
>
> The alternative, as you pointed out, is to take a module reference for
> each conntrack that uses the helper (and put again when connection is
> destroyed).

Yeah, this is exactly what I am suggesting and I fully expect this could
need more work than this barrier.

>
> I don't really care that much except that if we go for the latter
> solution users cannot "just rmmod" the module anymore but might have
> to manually remove the affected connections first.

This is not bad because the module is indeed being used in this scenario
so EBUSY is expected, or do we need to guarantee conntrack modules
are not held by existing connections?
