From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH nf-next] netns: add and use net_ns_barrier
Date: Tue, 13 Jun 2017 09:35:20 -0700
Message-ID: <CAM_iQpUtZZBXQNB+tWJikQNmCHBot3tp7vAsc6+Xnh5H__6++g@mail.gmail.com>
References: <20170530093812.10712-1-fw@strlen.de> <87y3tcj3n7.fsf@xmission.com>
 <20170601085259.GA6067@breakpoint.cc> <CAM_iQpXgrQcbrQsMVoomcsHtk4JffRjJ27FLRoignndAzFVkug@mail.gmail.com>
 <20170613061656.GF18283@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
        netfilter-devel@vger.kernel.org,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:33163 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753423AbdFMQft (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Jun 2017 12:35:49 -0400
In-Reply-To: <20170613061656.GF18283@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 12, 2017 at 11:16 PM, Florian Westphal <fw@strlen.de> wrote:
> Cong Wang <xiyou.wangcong@gmail.com> wrote:
>> On Thu, Jun 1, 2017 at 1:52 AM, Florian Westphal <fw@strlen.de> wrote:
>> > Joe described it nicely, problem is that after unload we may have
>> > conntracks that still have a nf_conn_help extension attached that
>> > has a pointer to a structure that resided in the (unloaded) module.
>>
>> Why not hold a refcnt for its module?
>
> That would work as well.
>
> I'm not sure its nice to disallow rmmod of helper modules if they are
> used by a connection however.

I am _not_ suggesting to disallow rmmod.

>
> Right now you can "rmmod nf_conntrack_foo" at any time and this should
> work just fine without first having to flush affected conntracks
> manually.

My point is that since netns wq could invoke code of that module,
why it doesn't hold a refcnt of that module?

I am not familiar with netfilter code base so not sure if that is
hard to do or not, but it looks more elegant than this barrier.
