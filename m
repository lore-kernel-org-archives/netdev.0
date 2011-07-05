From: Adam Katz <adamkatz0@gmail.com>
Subject: Re: libpcap and tc filters
Date: Tue, 5 Jul 2011 16:07:19 +0300
Message-ID: <CAA0qwj5aBWrsqHGddW9FBV2srdGwVMzJKe84BTyRH0Dkr6KgVQ@mail.gmail.com>
References: <CAA0qwj6fWJFVCDW9M9jZhvQnSTy=Pnyp0AhWFYT8FOiroq7C=Q@mail.gmail.com>
	<1309777908.26180.1.camel@mojatatu>
	<CAA0qwj70-qUQ+6NL=2LP05TyMN99MdL1BF8tko+v=DhdyjZjJQ@mail.gmail.com>
	<CAA0qwj7cH8Ah69fBMkXpGkwG77TH_ZqMhKwj-Cc8Vc=F5c9SSw@mail.gmail.com>
	<1309784740.26180.21.camel@mojatatu>
	<CAA0qwj4=bOU3LDsRk591AtBWx2c_6uFwk0M4-AGrnxCPKjbbrw@mail.gmail.com>
	<1309788416.26180.63.camel@mojatatu>
	<CAA0qwj4FUpfdux73WCxFcjX0xp-zNtMwncRRmN7ea1Kr9FX3Kw@mail.gmail.com>
	<1309863403.1765.0.camel@mojatatu>
	<1309870021.1765.41.camel@mojatatu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:39232 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754739Ab1GENHT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2011 09:07:19 -0400
Received: by iyb12 with SMTP id 12so5174677iyb.19
        for <netdev@vger.kernel.org>; Tue, 05 Jul 2011 06:07:19 -0700 (PDT)
In-Reply-To: <1309870021.1765.41.camel@mojatatu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

well, first of all, thanks A LOT for your effort.

second, I just took at the libpcap source code and it seems it's using
the same ETH_P_ALL option when binding to an interface. So based on
what you're saying, the same solution of patching libpcap and
replacing ETH_P_ALL with  ETH_P_IP should also make these rules work
with traffic sent using pure libpcap or any libpcap - based
application.

On Tue, Jul 5, 2011 at 3:47 PM, jamal <hadi@cyberus.ca> wrote:
> On Tue, 2011-07-05 at 06:56 -0400, jamal wrote:
>
>> I downloaded tcpreplay and reproduced the issue with your rules.
>> Will look into it..
>
> Ok - found out whats going on.
> tcprelay sendpacket_open_pf() does bind to ETH_P_ALL.
> You are sending IP packets (the name tcpreplay is misleading,
> this thing replays anything).
> Your filters are for ip packets as in:
> ---
> sudo tc filter add dev eth0 protocol ip parent 1: prio 1 u32 match ip
> dport 22 0xffff flowid 1:1
> ---
>
> You have two options:
>
> 1) If you change that to capture ETH_P_ALL it works.
> i.e
>
> ---
> sudo tc filter add dev eth0 protocol all parent 1: prio 1 u32 match ip
> dport 22 0xffff flowid 1:1
> ---
>
> Of course this is nasty if you are in a busy network, because _all_
> packets not just ip will look at your filters. If it is just an
> experimental setup, it may be a non-issue
>
> 2) Change tcpreplay to take an additional option so it binds to
> ETH_P_IP (and default stays as is today). The authors of the app
> may not like that option - but it is sensible if you know you are
> replaying ip packets.
>
> cheers,
> jamal
>
>
>
>
