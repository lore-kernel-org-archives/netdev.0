From: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
Subject: Re: [PATCH] inetpeer: reduce stack usage
Date: Tue, 12 Apr 2011 23:51:26 +0900
Message-ID: <20110412235126.63841dfe.shimoda.hiroaki@gmail.com>
References: <4D9E62D9.5010400@scotdoyle.com>
	<20110408121700.0aad53fe@nehalam>
	<4D9FE5BE.6060600@scotdoyle.com>
	<20110409161908.a2aca120.shimoda.hiroaki@gmail.com>
	<4DA39330.2030102@scotdoyle.com>
	<20110411183105.46e86684@nehalam>
	<4DA3CB4B.9090506@scotdoyle.com>
	<1302581384.3603.14.camel@edumazet-laptop>
	<1302582172.3603.18.camel@edumazet-laptop>
	<4DA3E074.5090603@scotdoyle.com>
	<1302587490.3603.22.camel@edumazet-laptop>
	<4DA3F909.5020609@scotdoyle.com>
	<1302593469.3603.44.camel@edumazet-laptop>
	<1302597580.3233.14.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Scot Doyle <lkml@scotdoyle.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:48732 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932198Ab1DLOvm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Apr 2011 10:51:42 -0400
Received: by vxi39 with SMTP id 39so4934913vxi.19
        for <netdev@vger.kernel.org>; Tue, 12 Apr 2011 07:51:41 -0700 (PDT)
In-Reply-To: <1302597580.3233.14.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 12 Apr 2011 10:39:40 +0200
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> On 64bit arches, we use 752 bytes of stack when cleanup_once() is called
> from inet_getpeer().
> 
> Lets share the avl stack to save ~376 bytes.
> 
> Before patch :
> 
> # objdump -d net/ipv4/inetpeer.o | scripts/checkstack.pl
> 
> 0x000006c3 unlink_from_pool [inetpeer.o]:		376
> 0x00000721 unlink_from_pool [inetpeer.o]:		376
> 0x00000cb1 inet_getpeer [inetpeer.o]:			376
> 0x00000e6d inet_getpeer [inetpeer.o]:			376
> 0x0004 inet_initpeers [inetpeer.o]:			112
> # size net/ipv4/inetpeer.o
>    text	   data	    bss	    dec	    hex	filename
>    5320	    432	     21	   5773	   168d	net/ipv4/inetpeer.o
> 
> After patch :
> 
> objdump -d net/ipv4/inetpeer.o | scripts/checkstack.pl 
> 0x00000c11 inet_getpeer [inetpeer.o]:			376
> 0x00000dcd inet_getpeer [inetpeer.o]:			376
> 0x00000ab9 peer_check_expire [inetpeer.o]:		328
> 0x00000b7f peer_check_expire [inetpeer.o]:		328
> 0x0004 inet_initpeers [inetpeer.o]:			112
> # size net/ipv4/inetpeer.o
>    text	   data	    bss	    dec	    hex	filename
>    5163	    432	     21	   5616	   15f0	net/ipv4/inetpeer.o
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Scot Doyle <lkml@scotdoyle.com>
> Cc: Stephen Hemminger <shemminger@vyatta.com>
> Cc: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>

I couldn't understand that actually cleanup_once() was called
from inet_getpeer() and then the stack overflow was hit,
but this patch surely reduces stack usage.

Reviewed-by: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>

Thanks.
