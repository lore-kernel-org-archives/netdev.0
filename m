From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH nf-next] netns: add and use net_ns_barrier
Date: Wed, 14 Jun 2017 09:20:25 -0500
Message-ID: <87wp8eabx2.fsf@xmission.com>
References: <20170530093812.10712-1-fw@strlen.de>
        <87y3tcj3n7.fsf@xmission.com> <20170601085259.GA6067@breakpoint.cc>
        <CAM_iQpXgrQcbrQsMVoomcsHtk4JffRjJ27FLRoignndAzFVkug@mail.gmail.com>
        <20170613061656.GF18283@breakpoint.cc>
        <CAM_iQpUtZZBXQNB+tWJikQNmCHBot3tp7vAsc6+Xnh5H__6++g@mail.gmail.com>
        <20170614084147.GC31030@salvia>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        Florian Westphal <fw@strlen.de>,
        netfilter-devel@vger.kernel.org,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20170614084147.GC31030@salvia> (Pablo Neira Ayuso's message of
        "Wed, 14 Jun 2017 10:41:47 +0200")
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pablo Neira Ayuso <pablo@netfilter.org> writes:

> Hi!
>
> On Tue, Jun 13, 2017 at 09:35:20AM -0700, Cong Wang wrote:
>> On Mon, Jun 12, 2017 at 11:16 PM, Florian Westphal <fw@strlen.de> wrote:
>> > Cong Wang <xiyou.wangcong@gmail.com> wrote:
>> >> On Thu, Jun 1, 2017 at 1:52 AM, Florian Westphal <fw@strlen.de> wrote:
>> >> > Joe described it nicely, problem is that after unload we may have
>> >> > conntracks that still have a nf_conn_help extension attached that
>> >> > has a pointer to a structure that resided in the (unloaded) module.
>> >>
>> >> Why not hold a refcnt for its module?
>> >
>> > That would work as well.
>> >
>> > I'm not sure its nice to disallow rmmod of helper modules if they are
>> > used by a connection however.
>> 
>> I am _not_ suggesting to disallow rmmod.
>> 
>> >
>> > Right now you can "rmmod nf_conntrack_foo" at any time and this should
>> > work just fine without first having to flush affected conntracks
>> > manually.
>> 
>> My point is that since netns wq could invoke code of that module,
>> why it doesn't hold a refcnt of that module?
>> 
>> I am not familiar with netfilter code base so not sure if that is
>> hard to do or not, but it looks more elegant than this barrier.
>
> Florian has added a new native interface to integrate helpers into
> nftables in a much better way than we do now, that allows much more
> fine grain configuration. This new interface bumps refcounts on
> helpers as you suggest.
>
> However, we still have to sort of keep the existing behaviour around,
> people has been relying on this rmmod feature to globally disable
> helpers. It's very old thing indeed and as you can see, very sparse
> grain for the netns era... But still I think we need this.
>
> So I'm inclined to take this, and keep an eye to deprecate this
> behaviour in a several years ahead once. Probably we can get rid of
> this barrier at some point.

Acked-by: "Eric W. Biederman" <ebiederm@xmission.com>

If it works I don't have any problems with the code and it sounds like
it works.

My apologies for the delay.  There is an email black hole between Forian
and myself and I missed his replies.  Which gave me a very distored
picture of the conversation.

Eric



