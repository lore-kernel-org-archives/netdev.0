From: Sam Russell <sam.h.russell@gmail.com>
Subject: Re: MPLS decap with iproute2
Date: Tue, 8 Dec 2015 20:26:12 +1300
Message-ID: <CAJm+voW-J-aMM_cqCghSOPtYW_LbtUrHOD8XsdMGjGawEhesuQ@mail.gmail.com>
References: <CAJm+voVUXPBXBRo98K6XS9pVEkN=fCJ4chRdQ=azcZO9ge9gEg@mail.gmail.com>
	<5666424C.3050801@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: roopa <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f178.google.com ([209.85.220.178]:35421 "EHLO
	mail-qk0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933163AbbLHH0N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2015 02:26:13 -0500
Received: by qkfb125 with SMTP id b125so17232867qkf.2
        for <netdev@vger.kernel.org>; Mon, 07 Dec 2015 23:26:12 -0800 (PST)
In-Reply-To: <5666424C.3050801@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks all for your help, I got it working with Robert and Roopa's
sysctl settings, the following works:

ip route -f mpls add 100 dev lo

On 8 December 2015 at 15:37, roopa <roopa@cumulusnetworks.com> wrote:
> On 12/7/15, 11:42 AM, Sam Russell wrote:
>> Hi,
>>
>> I've had success with the iproute2 manpage example for encapsulating
>> outgoing traffic in MPLS, but I've not found a way to add decap routes
>> inbound.
>>
>> I've tried "ip route -f mpls add 100 dev lo" and other variations, but I
>> get netlink errors back.
>>
>> Has this been built yet? Is there sample config that I can try out? I'm
>> running a home-built 4.3 kernel + iproute2 built from head (on ubuntu
>> 15.10) and am comfortable with perf and splashing around in the codebase if
>> need be.
>>
> Example below should work
>  ip -f mpls route add 100 as 200 via inet 10.1.1.2 dev eth0
>
> You have to enable mpls on the interface first:
> echo 1 > /proc/sys/net/mpls/conf/eth0/input
>
> multipath iproute2 patches are not in yet. Will submit them soon.
>
> let me know if you still get errors.
