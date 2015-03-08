From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH iproute2] route: label externally offloaded routes
Date: Sun, 8 Mar 2015 15:10:48 -0700
Message-ID: <CAE4R7bBKeWoDEv5SJfpm96d330Dc9ZpZpWVG-Dd45uH1mF64aA@mail.gmail.com>
References: <1425795335-6416-1-git-send-email-sfeldma@gmail.com>
	<20150308065744.GB1986@nanopsycho.orion>
	<CAJieiUgz9O7LFhzONx5JKRv0o4+6hSHNtRgKaaKAn2ph4jdC2g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jiri Pirko <jiri@resnulli.us>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f47.google.com ([209.85.192.47]:45480 "EHLO
	mail-qg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751959AbbCHWKt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Mar 2015 18:10:49 -0400
Received: by qgaj5 with SMTP id j5so24538436qga.12
        for <netdev@vger.kernel.org>; Sun, 08 Mar 2015 15:10:49 -0700 (PDT)
In-Reply-To: <CAJieiUgz9O7LFhzONx5JKRv0o4+6hSHNtRgKaaKAn2ph4jdC2g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 8, 2015 at 6:35 AM, Roopa Prabhu <roopa@cumulusnetworks.com> wrote:
>
>
> On Sat, Mar 7, 2015 at 10:57 PM, Jiri Pirko <jiri@resnulli.us> wrote:
>>
>> Sun, Mar 08, 2015 at 07:15:35AM CET, sfeldma@gmail.com wrote:
>> >From: Scott Feldman <sfeldma@gmail.com>
>> >
>> >On ip route print dump, label externally offloaded routes with
>> > "external".
>> >Offloaded routes are flagged with RTNH_F_EXTERNAL, a recent additon to
>> >net-next.  For example:
>> >
>> >$ ip route
>> >default via 192.168.0.2 dev eth0
>> >11.0.0.0/30 dev swp1  proto kernel  scope link  src 11.0.0.2 external
>> >11.0.0.4/30 via 11.0.0.1 dev swp1  proto zebra  metric 20 external
>> >11.0.0.8/30 dev swp2  proto kernel  scope link  src 11.0.0.10 external
>> >11.0.0.12/30 via 11.0.0.9 dev swp2  proto zebra  metric 20 external
>> >12.0.0.2  proto zebra  metric 30 external
>> >        nexthop via 11.0.0.1  dev swp1 weight 1
>> >        nexthop via 11.0.0.9  dev swp2 weight 1
>> >12.0.0.3 via 11.0.0.1 dev swp1  proto zebra  metric 20 external
>> >12.0.0.4 via 11.0.0.9 dev swp2  proto zebra  metric 20 external
>> >192.168.0.0/24 dev eth0  proto kernel  scope link  src 192.168.0.15
>> >
>> >Signed-off-by: Scott Feldman <sfeldma@gmail.com>
>>
> No objections to the patch.
>
> since this is now getting exposed to userspace and there were suggestions in
> the past to use words like 'hw' or 'offload' in place of 'external' here,
> checking to see if you are taking suggestions. If yes, would 'hw' or
> 'offloaded' be a better name for the flag ?.

We used "external" because that's what was used for marking FDB
entries.  I personally have no preference other than we be consistent
for each object offloaded externally.  There will be other objects
we'll need to tag, such as bonds, so if there is enough objection to
"external", we should make the change now for FIB abd FDB objects, and
be consistent with future objects.

-scott
