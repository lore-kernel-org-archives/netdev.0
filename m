From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [RFC] iproute: Add support for extended ack to rtnl_talk
Date: Thu, 18 May 2017 12:02:07 +0200
Message-ID: <591D711F.1000906@iogearbox.net>
References: <20170503235638.31116-1-stephen@networkplumber.org> <590AF624.6090808@iogearbox.net>        <7315b681-9c78-4bc1-ab74-64509ab5887d@gmail.com>        <20170504.104103.1628291573330660235.davem@davemloft.net>       <20170504094356.66590a9a@xeon-e3>       <20170504204318.GB21130@orbyte.nwl.cc>  <f847c8d4-a6c0-66ab-0ac0-d83d6ea96a00@gmail.com> <20170516093625.178caf3f@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Phil Sutter <phil@nwl.cc>, David Miller <davem@davemloft.net>,
        netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>,
        David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:60174 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753994AbdERKCT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 18 May 2017 06:02:19 -0400
In-Reply-To: <20170516093625.178caf3f@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/16/2017 06:36 PM, Stephen Hemminger wrote:
> On Sat, 13 May 2017 19:29:57 -0600
> David Ahern <dsahern@gmail.com> wrote:
>
>> On 5/4/17 2:43 PM, Phil Sutter wrote:
>>> So in summary, given that very little change happens to iproute2's
>>> internal libnetlink, I don't see much urge to make it use libmnl as
>>> backend. In my opinion it just adds another potential source of errors.
>>>
>>> Eventually this should be a maintainer level decision, though. :)
>>
>> What is the decision on this?
>
> I am waiting for a longer before committing anything. This was to allow
> for a wider range of distribution maintainer feedback.
>
> The most likely outcome is that for 4.12 is to use libmnl for extended ack.
> And continue to support building without mnl with loss of functionality.
>
> As far as conversion of all of iproute2 to libmnl. I have better things
> to do... But for new functionality like extended ack, devlink, tipc, using
> libmnl is easy, safe and it works well. I will continue to not accept
> new  code that depends on the other library (libnl). That has come up
> a couple of times.

So effectively this means libmnl has to be used for new stuff, noone
has time to do the work to convert the existing tooling over (which
by itself might be a challenge in testing everything to make sure
there are no regressions) given there's not much activity around
lib/libnetlink.c anyway, and existing users not using libmnl today
won't see/notice new improvements on netlink side when they do an
upgrade. So we'll be stuck with that dual library mess pretty much
for a very long time. :(

If there's such high desire to use libmnl (?), can't there be a
one time effort wrapping the core netlink code over, making a hard
cut for everyone where from one release to another the dependency
becomes really mandatory rather than optional? That's more work
initially, but still seems a lot better than growing a wild mix
of both over time where users see different behavior of the tools
depending on their setup. (This could perhaps also make actual
conversion much harder later on.)

Can't you add that lib conversion as a Google summer of code project,
so that someone is actively taking care of that initial work?
