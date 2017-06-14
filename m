From: David Ahern <dsahern@gmail.com>
Subject: Re: Repeatable inet6_dump_fib crash in stock 4.12.0-rc4+
Date: Wed, 14 Jun 2017 16:25:44 -0600
Message-ID: <8630b942-2684-2f21-fdb9-8474aba71528@gmail.com>
References: <bbfa5208-3a04-c87a-a6e1-ee0ae73965d0@candelatech.com>
 <a5733c67-e3a3-9cc0-0862-40ef6fc03de3@gmail.com>
 <1496795269.736.21.camel@edumazet-glaptop3.roam.corp.google.com>
 <da189b9d-760f-0591-2acf-1a6b7910e227@gmail.com>
 <1496809166.736.25.camel@edumazet-glaptop3.roam.corp.google.com>
 <94bcc041-6402-d0ce-b9cf-3b46aa622f34@candelatech.com>
 <CAM_iQpXM3G=J0tw=n1_mKno=i41Kmoxb00+nDyBWofWskj5P_A@mail.gmail.com>
 <7e0c97fa-cd6e-ed0f-bf99-0e4af40fbd2f@gmail.com>
 <1497043557.736.94.camel@edumazet-glaptop3.roam.corp.google.com>
 <9cb61ef0-37c0-8f35-bb5c-e3d8e63cbe2f@candelatech.com>
 <CAM_iQpV8u=aqn-AjeRw8CKQ=0Q6_gBvCCaYi2v3pJbYNL2WhJw@mail.gmail.com>
 <3230b360-528b-0ae0-8731-7906e57ee993@gmail.com>
 <4b65e262-e727-010a-ce1f-eb45fcef8e42@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        netdev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>,
        Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f41.google.com ([74.125.83.41]:32921 "EHLO
        mail-pg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752097AbdFNWZs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Jun 2017 18:25:48 -0400
Received: by mail-pg0-f41.google.com with SMTP id f185so6114987pgc.0
        for <netdev@vger.kernel.org>; Wed, 14 Jun 2017 15:25:47 -0700 (PDT)
In-Reply-To: <4b65e262-e727-010a-ce1f-eb45fcef8e42@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/14/17 4:23 PM, Ben Greear wrote:
> On 06/13/2017 07:27 PM, David Ahern wrote:
> 
>> Let's try a targeted debug patch. See attached
> 
> I had to change it to pr_err so it would go to our serial console
> since the system locked hard on crash,
> and that appears to be enough to change the timing where we can no longer
> reproduce the problem.


ok, let's figure out which one is doing that. There are 3 debug
statements. I suspect fib6_del_route is the one setting the state to
FWS_U. Can you remove the debug prints in fib6_repair_tree and
fib6_walk_continue and try again?
