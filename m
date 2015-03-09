From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH iproute2] route: label externally offloaded routes
Date: Mon, 9 Mar 2015 09:16:58 -0700
Message-ID: <CAE4R7bBwtGbB6FjJbEBXieYNRrqGknsC2FRQ2s270ySeEYNerQ@mail.gmail.com>
References: <1425795335-6416-1-git-send-email-sfeldma@gmail.com>
	<20150309140241.GI502@gospo.home.greyhouse.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>
To: Andy Gospodarek <gospo@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f182.google.com ([209.85.216.182]:33745 "EHLO
	mail-qc0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932680AbbCIQQ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2015 12:16:59 -0400
Received: by qcvx3 with SMTP id x3so3891153qcv.0
        for <netdev@vger.kernel.org>; Mon, 09 Mar 2015 09:16:58 -0700 (PDT)
In-Reply-To: <20150309140241.GI502@gospo.home.greyhouse.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 9, 2015 at 7:02 AM, Andy Gospodarek
<gospo@cumulusnetworks.com> wrote:
> On Sat, Mar 07, 2015 at 10:15:35PM -0800, sfeldma@gmail.com wrote:
>> From: Scott Feldman <sfeldma@gmail.com>
>>
>> On ip route print dump, label externally offloaded routes with "external".
>> Offloaded routes are flagged with RTNH_F_EXTERNAL, a recent additon to
>> net-next.  For example:
>>
>> $ ip route
>> default via 192.168.0.2 dev eth0
>> 11.0.0.0/30 dev swp1  proto kernel  scope link  src 11.0.0.2 external
>> 11.0.0.4/30 via 11.0.0.1 dev swp1  proto zebra  metric 20 external
>> 11.0.0.8/30 dev swp2  proto kernel  scope link  src 11.0.0.10 external
>> 11.0.0.12/30 via 11.0.0.9 dev swp2  proto zebra  metric 20 external
>> 12.0.0.2  proto zebra  metric 30 external
>>         nexthop via 11.0.0.1  dev swp1 weight 1
>>         nexthop via 11.0.0.9  dev swp2 weight 1
>> 12.0.0.3 via 11.0.0.1 dev swp1  proto zebra  metric 20 external
>> 12.0.0.4 via 11.0.0.9 dev swp2  proto zebra  metric 20 external
>> 192.168.0.0/24 dev eth0  proto kernel  scope link  src 192.168.0.15
>>
>> Signed-off-by: Scott Feldman <sfeldma@gmail.com>
>
> You know we cannot have a thread about nomenclature without a comment
> from me.  ;)
>
> My only concern about 'external' is whether or not people will gloss
> over it since many of the routes listed will be to networks that
> actually are external to the system.  That namespace collision could
> seem awkward if you are not a traditional follower of this list.
> Listing an FDB entry as 'external' does not have the same issue since
> all FDB entries are local to the system, so I didn't even
> think about the potential when that set was posted.
>
> I would like to just call this 'hardware' since that is what we appear
> to be using for offload and would make it clear to the user that this
> route was in hardware as well as in the kernel.  I'd say the same for
> FDB entries, too.
>
> Scott, you have lots of experience in both traditional and Linux worlds,
> do you think my concern about confusion is unnecessary?

Votes so far: 1 for "external", 1 for "hardware", 1 for "offload" or "hw".

Good point about confusion wrt routes to non-local networks.
