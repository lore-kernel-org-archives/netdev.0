From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: Repeatable inet6_dump_fib crash in stock 4.12.0-rc4+
Date: Tue, 13 Jun 2017 14:42:50 -0700
Message-ID: <CAM_iQpV8u=aqn-AjeRw8CKQ=0Q6_gBvCCaYi2v3pJbYNL2WhJw@mail.gmail.com>
References: <bbfa5208-3a04-c87a-a6e1-ee0ae73965d0@candelatech.com>
 <a5733c67-e3a3-9cc0-0862-40ef6fc03de3@gmail.com> <1496795269.736.21.camel@edumazet-glaptop3.roam.corp.google.com>
 <da189b9d-760f-0591-2acf-1a6b7910e227@gmail.com> <1496809166.736.25.camel@edumazet-glaptop3.roam.corp.google.com>
 <94bcc041-6402-d0ce-b9cf-3b46aa622f34@candelatech.com> <CAM_iQpXM3G=J0tw=n1_mKno=i41Kmoxb00+nDyBWofWskj5P_A@mail.gmail.com>
 <7e0c97fa-cd6e-ed0f-bf99-0e4af40fbd2f@gmail.com> <1497043557.736.94.camel@edumazet-glaptop3.roam.corp.google.com>
 <9cb61ef0-37c0-8f35-bb5c-e3d8e63cbe2f@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        David Ahern <dsahern@gmail.com>,
        netdev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f175.google.com ([209.85.128.175]:33939 "EHLO
        mail-wr0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752109AbdFMVnM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Jun 2017 17:43:12 -0400
Received: by mail-wr0-f175.google.com with SMTP id 77so14998657wrb.1
        for <netdev@vger.kernel.org>; Tue, 13 Jun 2017 14:43:11 -0700 (PDT)
In-Reply-To: <9cb61ef0-37c0-8f35-bb5c-e3d8e63cbe2f@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 13, 2017 at 1:16 PM, Ben Greear <greearb@candelatech.com> wrote:
> On 06/09/2017 02:25 PM, Eric Dumazet wrote:
>>
>> On Fri, 2017-06-09 at 07:27 -0600, David Ahern wrote:
>>>
>>> On 6/8/17 11:55 PM, Cong Wang wrote:
>>>> Apparently fn->parent is NULL here for some reason, but
>>>> I don't know if that is expected or not. If a simple NULL check
>>>> is not enough here, we have to trace why it is NULL.
>>>
>>>
>>> From my understanding, parent should not be null hence the attempts to
>>> fix access to table nodes under a lock. ie., figuring out why it is null
>>> here.
>
>
> If someone has more suggestions, I'll be happy to test.

Can you enable RT6_TRACE() by changing RT6_DEBUG
from 2 to 3? We may collect some useful log with it.

diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index d4bf2c6..1941595 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -37,7 +37,7 @@
 #include <net/ip6_fib.h>
 #include <net/ip6_route.h>

-#define RT6_DEBUG 2
+#define RT6_DEBUG 3

 #if RT6_DEBUG >= 3
 #define RT6_TRACE(x...) pr_debug(x)
