From: David Ahern <dsahern@gmail.com>
Subject: Re: Repeatable inet6_dump_fib crash in stock 4.12.0-rc4+
Date: Tue, 20 Jun 2017 23:03:04 -0400
Message-ID: <e026e624-fd52-9a3d-c7c4-e30d82a34520@gmail.com>
References: <94bcc041-6402-d0ce-b9cf-3b46aa622f34@candelatech.com>
 <CAM_iQpXM3G=J0tw=n1_mKno=i41Kmoxb00+nDyBWofWskj5P_A@mail.gmail.com>
 <7e0c97fa-cd6e-ed0f-bf99-0e4af40fbd2f@gmail.com>
 <1497043557.736.94.camel@edumazet-glaptop3.roam.corp.google.com>
 <9cb61ef0-37c0-8f35-bb5c-e3d8e63cbe2f@candelatech.com>
 <CAM_iQpV8u=aqn-AjeRw8CKQ=0Q6_gBvCCaYi2v3pJbYNL2WhJw@mail.gmail.com>
 <3230b360-528b-0ae0-8731-7906e57ee993@gmail.com>
 <4b65e262-e727-010a-ce1f-eb45fcef8e42@candelatech.com>
 <8630b942-2684-2f21-fdb9-8474aba71528@gmail.com>
 <09a00004-da54-dc8f-5806-9576bbf577c7@candelatech.com>
 <20170620180515.GB6104@unicorn.suse.cz>
 <46695455-c476-fa5c-f272-b8864898dd28@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        netdev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>,
        Michal Kubecek <mkubecek@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f179.google.com ([209.85.223.179]:32929 "EHLO
        mail-io0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753016AbdFUDDI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Jun 2017 23:03:08 -0400
Received: by mail-io0-f179.google.com with SMTP id t87so2794894ioe.0
        for <netdev@vger.kernel.org>; Tue, 20 Jun 2017 20:03:08 -0700 (PDT)
In-Reply-To: <46695455-c476-fa5c-f272-b8864898dd28@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/20/17 5:41 PM, Ben Greear wrote:
> On 06/20/2017 11:05 AM, Michal Kubecek wrote:
>> On Tue, Jun 20, 2017 at 07:12:27AM -0700, Ben Greear wrote:
>>> On 06/14/2017 03:25 PM, David Ahern wrote:
>>>> On 6/14/17 4:23 PM, Ben Greear wrote:
>>>>> On 06/13/2017 07:27 PM, David Ahern wrote:
>>>>>
>>>>>> Let's try a targeted debug patch. See attached
>>>>>
>>>>> I had to change it to pr_err so it would go to our serial console
>>>>> since the system locked hard on crash,
>>>>> and that appears to be enough to change the timing where we can no
>>>>> longer
>>>>> reproduce the problem.
>>>>
>>>>
>>>> ok, let's figure out which one is doing that. There are 3 debug
>>>> statements. I suspect fib6_del_route is the one setting the state to
>>>> FWS_U. Can you remove the debug prints in fib6_repair_tree and
>>>> fib6_walk_continue and try again?
>>>
>>> We cannot reproduce with just that one printf in the kernel either.  It
>>> must change the timing too much to trigger the bug.
>>
>> You might try trace_printk() which should have less impact (don't forget
>> to enable /proc/sys/kernel/ftrace_dump_on_oops).
> 
> We cannot reproduce with trace_printk() either.

I think that suggests the walker state is set to FWS_U in
fib6_del_route, and it is the FWS_U case in fib6_walk_continue that
triggers the fault -- the null parent (pn = fn->parent). So we have the
2 areas of code that are interacting.

I'm on a road trip through the end of this week with little time to
focus on this problem. I'll get back to you another suggestion when I can.
