From: David Ahern <dsahern@gmail.com>
Subject: Re: [RFC] iproute: Add support for extended ack to rtnl_talk
Date: Thu, 18 May 2017 21:24:42 -0700
Message-ID: <1c494983-24e0-cd8f-9a2a-5d2a83e0bbc2@gmail.com>
References: <20170503235638.31116-1-stephen@networkplumber.org>
 <590AF624.6090808@iogearbox.net>
 <7315b681-9c78-4bc1-ab74-64509ab5887d@gmail.com>
 <20170504.104103.1628291573330660235.davem@davemloft.net>
 <20170504094356.66590a9a@xeon-e3> <20170504204318.GB21130@orbyte.nwl.cc>
 <f847c8d4-a6c0-66ab-0ac0-d83d6ea96a00@gmail.com>
 <20170516093625.178caf3f@xeon-e3> <591D711F.1000906@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Phil Sutter <phil@nwl.cc>, David Miller <davem@davemloft.net>,
        netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>,
        Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:36847 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752261AbdESEYp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 May 2017 00:24:45 -0400
Received: by mail-pg0-f67.google.com with SMTP id h64so8301771pge.3
        for <netdev@vger.kernel.org>; Thu, 18 May 2017 21:24:45 -0700 (PDT)
In-Reply-To: <591D711F.1000906@iogearbox.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/18/17 3:02 AM, Daniel Borkmann wrote:
> So effectively this means libmnl has to be used for new stuff, noone
> has time to do the work to convert the existing tooling over (which
> by itself might be a challenge in testing everything to make sure
> there are no regressions) given there's not much activity around
> lib/libnetlink.c anyway, and existing users not using libmnl today
> won't see/notice new improvements on netlink side when they do an
> upgrade. So we'll be stuck with that dual library mess pretty much
> for a very long time. :(

lib/libnetlink.c with all of its duplicate functions weighs in at just
947 LOC -- a mere 12% of the code in lib/. From a total SLOC of iproute2
it is a negligible part of the code base.

Given that, there is very little gain -- but a lot of risk in
regressions -- in converting such a small, low level code base to libmnl
just for the sake of using a library - something Phil noted in his
cursory attempt at converting ip to libmnl. ie., The level effort
required vs the benefit is just not worth it.

There are so many other parts of the ip code base that need work with a
much higher return on the time investment.
