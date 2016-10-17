From: Baozeng Ding <sploving1@gmail.com>
Subject: Re: net/ipv6: potential deadlock in do_ipv6_setsockopt
Date: Mon, 17 Oct 2016 17:54:57 +0800
Message-ID: <ec7e340c-132f-549d-9c30-b6e903cc7666@gmail.com>
References: <f43836e6-82b2-4673-1f5e-cd41ba0bc609@gmail.com>
 <CAM_iQpWKfkkYzF6yb9fGQsieGwok196kqGtRNVVS_ULxZghyew@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:33605 "EHLO
        mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932687AbcJQJzH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2016 05:55:07 -0400
Received: by mail-pf0-f176.google.com with SMTP id 128so78135614pfz.0
        for <netdev@vger.kernel.org>; Mon, 17 Oct 2016 02:55:07 -0700 (PDT)
In-Reply-To: <CAM_iQpWKfkkYzF6yb9fGQsieGwok196kqGtRNVVS_ULxZghyew@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Applied the patch to my test tree. I will tell you the result a few days later. Thank you.

On 2016/10/17 2:50, Cong Wang wrote:
> On Sun, Oct 16, 2016 at 6:34 AM, Baozeng Ding <sploving1@gmail.com> wrote:
>>  Possible unsafe locking scenario:
>>
>>        CPU0                    CPU1
>>        ----                    ----
>>   lock([  165.136033] sk_lock-AF_INET6
>> );
>>                                lock([  165.136033] rtnl_mutex
>> );
>>                                lock([  165.136033] sk_lock-AF_INET6
>> );
>>   lock([  165.136033] rtnl_mutex
>> );
>>
>>  *** DEADLOCK ***
> 
> This is caused by the conditional rtnl locking in do_ipv6_setsockopt().
> It looks like we miss the case of IPV6_ADDRFORM.
> 
> Please try the attached patch.
> 
