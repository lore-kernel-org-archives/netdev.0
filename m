From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: Race with ip=dhcp bootparameter in ip_rcv_finish on am335x
Date: Wed, 23 Sep 2015 12:36:13 +0200
Message-ID: <5602809D.2020500@cumulusnetworks.com>
References: <20150923102953.GA8918@omega>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Alexander Aring <alex.aring@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:32894 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753687AbbIWKgQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2015 06:36:16 -0400
Received: by wiclk2 with SMTP id lk2so232552269wic.0
        for <netdev@vger.kernel.org>; Wed, 23 Sep 2015 03:36:15 -0700 (PDT)
In-Reply-To: <20150923102953.GA8918@omega>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/23/2015 12:29 PM, Alexander Aring wrote:
> Hi,
> 
> I am using am335x (beaglebone white) with "ip=dhcp" inside my
> bootparameters. It seems there exists some race, rarely it boots fine
> and often it crashed with following messages:
> 
> First (Without successful dhcp ip assign and is very rarely):
> 
> [    6.249083] IPv6: ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
> [    6.398943] .
> [    7.400822] Unable to handle kernel paging request at virtual address 7402a8c8
> [    7.408419] pgd = c0004000
> [    7.411351] [7402a8c8] *pgd=00000000
> [    7.415121] Internal error: Oops: 5 [#1] SMP ARM
> [    7.419968] Modules linked in:
> [    7.423197] CPU: 0 PID: 0 Comm: swapper/0 Tainted: G        W       4.2.0-11195-ge81be90 #124
> [    7.432118] Hardware name: Generic AM33XX (Flattened Device Tree)
> [    7.438509] task: c0a996c8 ti: c0a92000 task.ti: c0a92000
> [    7.444189] PC is at ip_route_input_noref+0x620/0xeb4
> [    7.449491] LR is at trace_hardirqs_on_caller+0xb0/0x1e8
<<<snip>>>
> [    7.759169] [<c054b49c>] (ip_route_input_noref) from [<c0550668>] (ip_rcv_finish+0xd4/0x67c)
<<<snip>>>
> 
> --------
> 
> I tried to bisect this issue without success, sometimes it's booting fine
> and sometimes I got the above messages. Could anybody help me here to
> fixing this issue?
> 
> - Alex

Hi Alex,
This should be fixed by commit bde6f9ded1bd 
("net: Initialize table in fib result") in net-next.

Cheers,
 Nik
