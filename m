From: Baozeng Ding <sploving1@gmail.com>
Subject: Re: net/ipv6: potential deadlock in do_ipv6_setsockopt
Date: Wed, 19 Oct 2016 21:44:26 +0800
Message-ID: <95d6f5e9-cd87-6e23-6476-746243d4014e@gmail.com>
References: <f43836e6-82b2-4673-1f5e-cd41ba0bc609@gmail.com>
 <CAM_iQpWKfkkYzF6yb9fGQsieGwok196kqGtRNVVS_ULxZghyew@mail.gmail.com>
 <ec7e340c-132f-549d-9c30-b6e903cc7666@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>, sploving1@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f45.google.com ([209.85.218.45]:33840 "EHLO
        mail-oi0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S942017AbcJSOo3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2016 10:44:29 -0400
Received: by mail-oi0-f45.google.com with SMTP id t73so33013650oie.1
        for <netdev@vger.kernel.org>; Wed, 19 Oct 2016 07:44:29 -0700 (PDT)
In-Reply-To: <ec7e340c-132f-549d-9c30-b6e903cc7666@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


It fixes the issue for me. 
Tested-by: Baozeng Ding <sploving1@gmail.com>

On 2016/10/17 17:54, Baozeng Ding wrote:
> Applied the patch to my test tree. I will tell you the result a few days later. Thank you.
> 
> On 2016/10/17 2:50, Cong Wang wrote:
>> On Sun, Oct 16, 2016 at 6:34 AM, Baozeng Ding <sploving1@gmail.com> wrote:
>>>  Possible unsafe locking scenario:
>>>
>>>        CPU0                    CPU1
>>>        ----                    ----
>>>   lock([  165.136033] sk_lock-AF_INET6
>>> );
>>>                                lock([  165.136033] rtnl_mutex
>>> );
>>>                                lock([  165.136033] sk_lock-AF_INET6
>>> );
>>>   lock([  165.136033] rtnl_mutex
>>> );
>>>
>>>  *** DEADLOCK ***
>>
>> This is caused by the conditional rtnl locking in do_ipv6_setsockopt().
>> It looks like we miss the case of IPV6_ADDRFORM.
>>
>> Please try the attached patch.
>>
