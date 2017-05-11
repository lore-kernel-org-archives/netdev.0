From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH] ip: mpls: fix printing of mpls labels
Date: Thu, 11 May 2017 13:52:47 -0700
Message-ID: <61f9b581-77d4-3ece-4f16-225afdb6af58@gmail.com>
References: <20170509060413.11596-1-dsahern@gmail.com>
 <20170511110941.344a3011@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:33513 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755197AbdEKUwz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 11 May 2017 16:52:55 -0400
Received: by mail-pf0-f194.google.com with SMTP id a23so4506781pfe.0
        for <netdev@vger.kernel.org>; Thu, 11 May 2017 13:52:55 -0700 (PDT)
In-Reply-To: <20170511110941.344a3011@xeon-e3>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/11/17 11:09 AM, Stephen Hemminger wrote:
> On Mon,  8 May 2017 23:04:13 -0700
> David Ahern <dsahern@gmail.com> wrote:
> 
>> If the kernel returns more labels than iproute2 expects, none of
>> the labels are printed and (null) is shown instead:
>>     $ ip -f mpls ro ls
>>     101 as to (null) via inet 172.16.2.2 dev virt12
>>     201 as to 202/203 via inet6 2001:db8:2::2 dev virt12
>>
>> Remove the use of MPLS_MAX_LABELS and rely on buffer length that is
>> passed to mpls_ntop. With this change ip can print the label stack
>> returned by the kernel up to 255 characters (limit is due to size of
>> buf passed in) which amounts to 31 labels with a separator.
>>
>> With this change the above is:
>>     $ ip/ip -f mpls ro ls
>>     101 as to 102/103/104/105/106/107/108/109/110 via inet 172.16.2.2 dev virt12
>>
>> Signed-off-by: David Ahern <dsahern@gmail.com>
> 
> Much better. Applied thanks.
> 

This is only one-half of the solution; the install side is harder. I'll
send something in the next few days.
