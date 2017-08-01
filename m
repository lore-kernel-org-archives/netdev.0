From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH net-next 00/10] net: l3mdev: Support for sockets bound to
 enslaved device
Date: Tue, 1 Aug 2017 08:45:29 -0600
Message-ID: <7169d6d7-d0a7-5f17-185d-f95fe2d5f5ba@gmail.com>
References: <1501557206-27503-1-git-send-email-dsahern@gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6DD00482E4@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
To: David Laight <David.Laight@ACULAB.COM>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:38321 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751368AbdHAOpd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2017 10:45:33 -0400
Received: by mail-pg0-f65.google.com with SMTP id 123so1234062pga.5
        for <netdev@vger.kernel.org>; Tue, 01 Aug 2017 07:45:33 -0700 (PDT)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DD00482E4@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/1/17 8:15 AM, David Laight wrote:
> From: David Ahern
>> Sent: 01 August 2017 04:13
> ...
>> Existing code for socket lookups already pass in 6+ arguments. Rather
>> than add another for the enslaved device index, the existing lookups
>> are converted to use a new sk_lookup struct. From there, the enslaved
>> device index becomes another element of the struct.
>>
>> Patch 1 introduces sk_lookup struct and helper.
> 
> I guess that socket lookup happens quite often!
> Passing the lookup parameters in a structure might have a
> measurable negative effect on performance - especially if the
> structure isn't passed through to other functions.
> 
> Have you made any performance mearurements?


Before patches:

IPv4
   Test   TCP_RR       23769.42     23862.59     23867.69  sum
71499.70  avg      23833
   Test  TCP_CRR        8649.29      8650.94      8661.24  sum
25961.47  avg       8653
   Test   UDP_RR       26935.38     26813.30     26747.88  sum
80496.56  avg      26832

IPv6
   Test   TCP_RR       24708.10     24629.43     24593.75  sum
73931.28  avg      24643
   Test  TCP_CRR        8432.82      8489.26      8474.82  sum
25396.90  avg       8465
   Test   UDP_RR       23607.57     23722.37     23713.80  sum
71043.74  avg      23681


#################################################################
After patches:

IPv4
   Test   TCP_RR       24204.41     23993.05     24129.18  sum
72326.64  avg      24108
   Test  TCP_CRR        8690.31      8630.12      8620.88  sum
25941.31  avg       8647
   Test   UDP_RR       26653.26     26725.76     26587.70  sum
79966.72  avg      26655

IPv6
   Test   TCP_RR       24807.54     24698.30     24849.84  sum
74355.68  avg      24785
   Test  TCP_CRR        8573.22      8640.02      8624.09  sum
25837.33  avg       8612
   Test   UDP_RR       23800.14     23747.01     23814.94  sum
71362.09  avg      23787

The middle columns are the results of each 30-second run and then the
average of the 3 is on the end.
