From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [RFC] iproute: Add support for extended ack to rtnl_talk
Date: Sat, 6 May 2017 12:36:04 +0200
Message-ID: <20170506103604.GA2017@nanopsycho>
References: <20170503235638.31116-1-stephen@networkplumber.org>
 <590AF624.6090808@iogearbox.net>
 <20170504143738.GY22833@mtr-leonro.local>
 <20170504094558.78933e60@xeon-e3>
 <20170504175556.GZ22833@mtr-leonro.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org
To: Leon Romanovsky <leon@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:34784 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751978AbdEFKgI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 6 May 2017 06:36:08 -0400
Received: by mail-wr0-f195.google.com with SMTP id 6so2808263wrb.1
        for <netdev@vger.kernel.org>; Sat, 06 May 2017 03:36:08 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170504175556.GZ22833@mtr-leonro.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, May 04, 2017 at 07:55:56PM CEST, leon@kernel.org wrote:
>On Thu, May 04, 2017 at 09:45:58AM -0700, Stephen Hemminger wrote:
>> On Thu, 4 May 2017 17:37:38 +0300
>> Leon Romanovsky <leon@kernel.org> wrote:
>>
>> > On Thu, May 04, 2017 at 11:36:36AM +0200, Daniel Borkmann wrote:
>> > > On 05/04/2017 01:56 AM, Stephen Hemminger wrote:
>> > > > Add support for extended ack error reporting via libmnl. This
>> > > > is a better alternative to use existing library and not copy/paste
>> > > > code from the kernel. Also make arguments const where possible.
>> > > >
>> > > > Add a new function rtnl_talk_extack that takes a callback as an input
>> > > > arg. If a netlink response contains extack attributes, the callback is
>> > > > is invoked with the the err string, offset in the message and a pointer
>> > > > to the message returned by the kernel.
>> > > >
>> > > > Adding a new function allows commands to be moved over to the
>> > > > extended error reporting over time.
>> > > >
>> > > > For feedback, compile tested only.
>> > >
>> > > Just out of curiosity, what is the plan regarding converting iproute2
>> > > over to libmnl (ip, tc, ss, ...)? In 2015, tipc tool was the first
>> > > user merged that requires libmnl, the only other user today in the
>> > > tree is devlink, which even seems to define its own libmnl library
>> > > helpers. What is the clear benefit/rationale of outsourcing this to
>> > > libmnl? I always was the impression we should strive for as little
>> > > dependencies as possible?
>> >
>> > And I would like to get direction for the RDMA tool [1] which I'm
>> > working on it now.
>> >
>> > The overall decision was to use netlink and put it under iproute2
>> > umbrella. Currently, I have working RFC which is based on
>> > legacy sysfs interface to ensure that we are converging on
>> > user-experience even before moving to actual netlink defines.
>> >
>> > An I would like to continue to work on netlink interface, but which lib interface
>> > should I need to base rdmatool's netlink code?
>> >
>> > [1] https://www.mail-archive.com/netdev@vger.kernel.org/msg148523.html
>> >
>> > >
>> > > I don't really like that we make extended ack reporting now dependent
>> > > on libmnl, which further diverts from iproute's native nl library vs
>> > > requiring to install another nl library, making the current status
>> > > quo even worse ... :/
>> > >
>> > > Thanks,
>> > > Daniel
>>
>> I would prefer new code use libmnl, but using libnetlink would also be ok.
>> Any later conversion to libmnl would be mostly automated anyway.
>
>Thanks, I'm copy/pasting devlink variation of libmnl :)

I needed couple of small helpers for generic netlink support. I believe
they could be pushed to upstream libmnl so we can avoid having them in
iproute2


>
>>
>> The real objection was copy/pasting in the kernel netlink parser.
>> That was unnecessary bloat.
>
>
