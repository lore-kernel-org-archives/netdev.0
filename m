From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next] net: Fix vti use case with oif in dst lookups
 for IPv6
Date: Sun, 11 Oct 2015 12:01:30 -0600
Message-ID: <561AA3FA.7070001@cumulusnetworks.com>
References: <1444055571-82546-1-git-send-email-dsa@cumulusnetworks.com>
 <m2a8rs7crl.wl@gmail.com> <20151009071710.GJ7701@secunet.com>
 <5617F908.8060807@cumulusnetworks.com> <m21td17d5p.wl@gmail.com>
 <561A64B4.5080301@cumulusnetworks.com> <m2zizp5vqm.wl@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, netdev@vger.kernel.org
To: Hajime Tazaki <thehajime@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:36829 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751432AbbJKSB2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Oct 2015 14:01:28 -0400
Received: by pablk4 with SMTP id lk4so133190665pab.3
        for <netdev@vger.kernel.org>; Sun, 11 Oct 2015 11:01:28 -0700 (PDT)
In-Reply-To: <m2zizp5vqm.wl@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/11/15 8:24 AM, Hajime Tazaki wrote:
>
> I've faced this issue since the following patch was applied.
>
> commit 741a11d9e4103a8e1c590ef1280143fe654e4e33
> Author: David Ahern <dsa@cumulusnetworks.com>
> Date:   Mon Sep 28 10:12:13 2015 -0700
>
>      net: ipv6: Add RT6_LOOKUP_F_IFACE flag if oif is set
>
> I still couldn't spot which part (other than my posted call
> graph) is broken and am not sure whether the xfrm change
> affects or not (which I need to check the mip6 code again).

Ok, this is a separate problem from what Steffen is hitting.

>
>> Can you apply this patch, and then run:
>>
>> perf record -e fib6:* -a -g
>> perf script
>
> I'm using libos environment right now, so the perf trace
> can't be used as it is.

ok.

Some path in raw6_sendmsg is setting fl6.flowi6_oif. Can you instrument it?
