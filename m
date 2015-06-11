From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next 0/3 v3] changes to make ipv4 routing table aware
 of next-hop link status
Date: Thu, 11 Jun 2015 08:44:55 -0700
Message-ID: <CAE4R7bC6ETRRdkm02V8gcnAEmp=Te+jczSqX9nsOPGs13_jtGA@mail.gmail.com>
References: <1433990233-958-1-git-send-email-gospo@cumulusnetworks.com>
 <CAE4R7bChX1AtwoeC12ei1hr-3CJnZwPig8YXKpvAuhHSRyVYLg@mail.gmail.com> <20150611031916.GW588@gospo.home.greyhouse.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>, ddutt@cumulusnetworks.com,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>
To: Andy Gospodarek <gospo@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f177.google.com ([209.85.220.177]:33177 "EHLO
	mail-qk0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751159AbbFKPpQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2015 11:45:16 -0400
Received: by qkhg32 with SMTP id g32so4816977qkh.0
        for <netdev@vger.kernel.org>; Thu, 11 Jun 2015 08:45:15 -0700 (PDT)
In-Reply-To: <20150611031916.GW588@gospo.home.greyhouse.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 10, 2015 at 8:19 PM, Andy Gospodarek
<gospo@cumulusnetworks.com> wrote:
> On Wed, Jun 10, 2015 at 08:07:10PM -0700, Scott Feldman wrote:
>> On Wed, Jun 10, 2015 at 7:37 PM, Andy Gospodarek
>> <gospo@cumulusnetworks.com> wrote:
>>
>> > There was also a request for switchdev support for this, but that will be
>> > posted as a followup as switchdev does not currently handle dead
>> > next-hops in a multi-path case and I felt that infra needed to be added
>> > first.
>>
>> That's not true.  switchdev_fib_ipv4_add() passes *fi and all of the
>> nexthops for the route are hanging off of that, including the
>> nh->flags where you're setting LINKDOWN.  Multipath is not different
>> than singlepath in that regard.  Same API for both.
>
> The API is the same, but I did not see a path that would take a
> multipath route and update the dead nexthops when an interface is taken
> down with switchdev or rocker today.
>
> I could be wrong (and I will test again), but create a multipath route
> with nexthops on swp1 and swp2 and then call 'ip link set swp1 down' and
> let me know if you see rocker's ECMP routes get updated so only the
> nexthop on swp2 will be used.

I don't have ecmp support in rocker yet, but switchdev should be ready
for ecmp.  I tried the test you suggest and switchdev is calling into
the driver with updates to the routes with nhs marked DEAD.  So maybe
your patchset is switchdev-ready?  I'd have to apply your patch to
test. I'll wait for your v4 to address sysctl naming.
