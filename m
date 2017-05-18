From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [RFC] iproute: Add support for extended ack to rtnl_talk
Date: Thu, 18 May 2017 07:55:17 -0700
Message-ID: <20170518075517.2c8b1c56@xeon-e3>
References: <20170503235638.31116-1-stephen@networkplumber.org>
        <590AF624.6090808@iogearbox.net>
        <7315b681-9c78-4bc1-ab74-64509ab5887d@gmail.com>
        <20170504.104103.1628291573330660235.davem@davemloft.net>
        <20170504094356.66590a9a@xeon-e3>
        <20170504204318.GB21130@orbyte.nwl.cc>
        <f847c8d4-a6c0-66ab-0ac0-d83d6ea96a00@gmail.com>
        <20170516093625.178caf3f@xeon-e3>
        <591D711F.1000906@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Ahern <dsahern@gmail.com>, Phil Sutter <phil@nwl.cc>,
        David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f42.google.com ([74.125.83.42]:34131 "EHLO
        mail-pg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933180AbdEROzZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 18 May 2017 10:55:25 -0400
Received: by mail-pg0-f42.google.com with SMTP id u28so24031922pgn.1
        for <netdev@vger.kernel.org>; Thu, 18 May 2017 07:55:25 -0700 (PDT)
In-Reply-To: <591D711F.1000906@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 18 May 2017 12:02:07 +0200
Daniel Borkmann <daniel@iogearbox.net> wrote:

> On 05/16/2017 06:36 PM, Stephen Hemminger wrote:
> > On Sat, 13 May 2017 19:29:57 -0600
> > David Ahern <dsahern@gmail.com> wrote:
> >  
> >> On 5/4/17 2:43 PM, Phil Sutter wrote:  
> >>> So in summary, given that very little change happens to iproute2's
> >>> internal libnetlink, I don't see much urge to make it use libmnl as
> >>> backend. In my opinion it just adds another potential source of errors.
> >>>
> >>> Eventually this should be a maintainer level decision, though. :)  
> >>
> >> What is the decision on this?  
> >
> > I am waiting for a longer before committing anything. This was to allow
> > for a wider range of distribution maintainer feedback.
> >
> > The most likely outcome is that for 4.12 is to use libmnl for extended ack.
> > And continue to support building without mnl with loss of functionality.
> >
> > As far as conversion of all of iproute2 to libmnl. I have better things
> > to do... But for new functionality like extended ack, devlink, tipc, using
> > libmnl is easy, safe and it works well. I will continue to not accept
> > new  code that depends on the other library (libnl). That has come up
> > a couple of times.  
> 
> So effectively this means libmnl has to be used for new stuff, noone
> has time to do the work to convert the existing tooling over (which
> by itself might be a challenge in testing everything to make sure
> there are no regressions) given there's not much activity around
> lib/libnetlink.c anyway, and existing users not using libmnl today
> won't see/notice new improvements on netlink side when they do an
> upgrade. So we'll be stuck with that dual library mess pretty much
> for a very long time. :(
> 
> If there's such high desire to use libmnl (?), can't there be a
> one time effort wrapping the core netlink code over, making a hard
> cut for everyone where from one release to another the dependency
> becomes really mandatory rather than optional? That's more work
> initially, but still seems a lot better than growing a wild mix
> of both over time where users see different behavior of the tools
> depending on their setup. (This could perhaps also make actual
> conversion much harder later on.)

If nothing else it would be simple experiment to do libnetlink
to libmnl wrappers in libnetlink.h

> Can't you add that lib conversion as a Google summer of code project,
> so that someone is actively taking care of that initial work?

Agreed
