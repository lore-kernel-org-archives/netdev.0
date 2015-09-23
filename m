From: Alexander Aring <alex.aring@gmail.com>
Subject: Re: Race with ip=dhcp bootparameter in ip_rcv_finish on am335x
Date: Wed, 23 Sep 2015 13:09:16 +0200
Message-ID: <20150923110911.GA11212@omega>
References: <20150923102953.GA8918@omega>
 <5602809D.2020500@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:34975 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754042AbbIWLJX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2015 07:09:23 -0400
Received: by wicge5 with SMTP id ge5so202083542wic.0
        for <netdev@vger.kernel.org>; Wed, 23 Sep 2015 04:09:22 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <5602809D.2020500@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Wed, Sep 23, 2015 at 12:36:13PM +0200, Nikolay Aleksandrov wrote:
> On 09/23/2015 12:29 PM, Alexander Aring wrote:
> > Hi,
> > 
> > I am using am335x (beaglebone white) with "ip=dhcp" inside my
> > bootparameters. It seems there exists some race, rarely it boots fine
> > and often it crashed with following messages:
> > 
> > First (Without successful dhcp ip assign and is very rarely):
> > 
> > [    6.249083] IPv6: ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
> > [    6.398943] .
> > [    7.400822] Unable to handle kernel paging request at virtual address 7402a8c8
> > [    7.408419] pgd = c0004000
> > [    7.411351] [7402a8c8] *pgd=00000000
> > [    7.415121] Internal error: Oops: 5 [#1] SMP ARM
> > [    7.419968] Modules linked in:
> > [    7.423197] CPU: 0 PID: 0 Comm: swapper/0 Tainted: G        W       4.2.0-11195-ge81be90 #124
> > [    7.432118] Hardware name: Generic AM33XX (Flattened Device Tree)
> > [    7.438509] task: c0a996c8 ti: c0a92000 task.ti: c0a92000
> > [    7.444189] PC is at ip_route_input_noref+0x620/0xeb4
> > [    7.449491] LR is at trace_hardirqs_on_caller+0xb0/0x1e8
> <<<snip>>>
> > [    7.759169] [<c054b49c>] (ip_route_input_noref) from [<c0550668>] (ip_rcv_finish+0xd4/0x67c)
> <<<snip>>>
> > 
> > --------
> > 
> > I tried to bisect this issue without success, sometimes it's booting fine
> > and sometimes I got the above messages. Could anybody help me here to
> > fixing this issue?
> > 
> > - Alex
> 
> Hi Alex,
> This should be fixed by commit bde6f9ded1bd 
> ("net: Initialize table in fib result") in net-next.
> 

I tried to cherry-picked this commit and saw this is already in net-next.
I also tried to boot current net, the race is still there.

- Alex
