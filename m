From: Cong Wang <cwang@twopensource.com>
Subject: Re: [Patch net-next v2 0/5] fou: some fixes and updates
Date: Fri, 10 Apr 2015 13:50:55 -0700
Message-ID: <CAHA+R7MLifECseX=R4R6ZSz=JYhBBcNrqkSpu51rQ833OKXdjg@mail.gmail.com>
References: <1428692430-14465-1-git-send-email-xiyou.wangcong@gmail.com>
	<CALx6S37WGT7p=ZMLc+ZOiXmvjQxaxG+k6yR2m2h9SEn5Av5xjg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:37460 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753864AbbDJUu4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Apr 2015 16:50:56 -0400
Received: by wiaa2 with SMTP id a2so10286772wia.0
        for <netdev@vger.kernel.org>; Fri, 10 Apr 2015 13:50:55 -0700 (PDT)
In-Reply-To: <CALx6S37WGT7p=ZMLc+ZOiXmvjQxaxG+k6yR2m2h9SEn5Av5xjg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 10, 2015 at 1:38 PM, Tom Herbert <tom@herbertland.com> wrote:
> On Fri, Apr 10, 2015 at 12:00 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>> Patch 1~3 fix some minor bugs in net/ipv4/fou.c, the only
>> thing I am not sure is if it's too late to change the
>> byte order of FOU_ATTR_PORT, if so we have to fix iproute2
>> instead of kernel.
>>
> Is this a relic from previous patch set, or is there a reason you want
> to make this hbo?

I was referring to this change:

-               u16 port = nla_get_u16(info->attrs[FOU_ATTR_PORT]);
+               __be16 port = nla_get_be16(info->attrs[FOU_ATTR_PORT]);

I meant I am not sure if this breaks ABI here even in v2, we
just use the raw value passed from user-space, so probably
we are safe.

>
>> Patch 4~5 add some new features to make it complete.
>>
>> v2: make fou->port be16 too
>>
>> Cong Wang (5):
>>   fou: avoid calling udp_del_offload() twice
>>   fou: exit early when parsing config fails
>>   fou: always use be16 for port
>>   fou: add network namespace support
>>   fou: implement FOU_CMD_GET
>>
>
> I assume you didn't see any adverse performance impact with these patches?
>

I don't think I touch any hot path, foo_create() and foo_destroy() are
both slow path.

Thanks.
