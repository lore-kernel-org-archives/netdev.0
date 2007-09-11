From: Bill Davidsen <davidsen@tmr.com>
Subject: Re: sk98lin for 2.6.23-rc1
Date: Tue, 11 Sep 2007 10:29:47 -0400
Message-ID: <46E6A65B.2050209@tmr.com>
References: <20070905102230.10b0bdcf@oldman> <782111.42803.qm@web90413.mail.mud.yahoo.com> <46E2DF74.7040307@tmr.com> <20070908191132.GD3563@stusta.de> <46E35D8C.1070909@krose.org> <20070909111326.GF3563@stusta.de> <20070911100526.6aa5d463@oldman> <20070911115456.GM3563@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	Kyle Rose <krose@krose.org>,
	James Corey <ploversegg@yahoo.com>,
	Rob Sims <lkml-z@robsims.com>, linux-kernel@vger.kernel.org,
	Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org
To: Adrian Bunk <bunk@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.tmr.com ([64.65.253.246]:45883 "EHLO gaimboi.tmr.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751492AbXIKO1u (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Sep 2007 10:27:50 -0400
In-Reply-To: <20070911115456.GM3563@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adrian Bunk wrote:
> On Tue, Sep 11, 2007 at 10:05:26AM +0200, Stephen Hemminger wrote:
>   
>> There are several different problems in this thread:
>> 1. The removal of old sk98lin driver caused some users to be forced to use
>>     skge. These users have uncovered issues with the dual port fiber based versions
>>     of the board.  
>>     Short term: The sk98lin driver should be restored to previous state, 
>>        and the PCI table should be used to limit the usage to only fiber systems.
>>        If Adrian doesn't do it, I'll do it when I return from Germany.
>> ...
>>     
>
> No problem with this, but since it was Jeff's patch it should better be 
> him who reverts it (and he's anyway one step nearer to Linus).
>
> But the underlying general problem still remains:
>
> How can we get people to test and report bugs with the new drivers 
> before removing the old driver?
>
>   
Sorry for a long answer, I'm trying to provide insight on two recent cases.

Thinking back to several drivers, when e100 was new I tried it because I 
had problems with eepro100 in the area of multiple cards, multiple 
cables on a single card, and jumbo packets. For a while I used both, 
until e100 worked where I need it. So I initially tried it because it 
had features I needed, and then dropped to older driver just to avoid 
having to decide.

With sk98lin, the driver worked flawlessly with all (3-4) systems, so I 
had no reason to try any other. When removing sk98lin was first 
proposed, I tried skge, first measurements showed it was 5-8% slower, 
NOT what I want, so I went back. For me there was no reliability issue, 
but I never tried it in a system with more than on NIC on the driver. 
Would "it's a little slower" be a valid bug report? Or would I have 
gotten "works fine for me" from people not beating it over Gbit? I 
didn't try sky2 until you suggested it, and I have reported my results 
previously, just stops working. Could it be my hardware? I tried it on 
one system, so yes, but sk98lin works for months.
> That's a question especially for the people who now had problems after 
> sk98lin was removed.

So if you want people to try a new driver, I think it really has to have 
some benefits to the users, in terms of performance, reliability, or 
features. "Cleaner design" doesn't motivate, and it does raise the 
question of why the old driver wasn't just cleaned up. I've been doing 
software for decades, I appreciate why, but users in general just want 
to use their system. Which raises the question of why to delete drivers 
which work for many or even most users? Testing a new kernel is no 
longer a drop in a boot operation if modprobe.conf must be edited to get 
the network up, and the typical user isn't going to write that shell 
script to try one or the other driver.

Honestly, new drivers which offer little benefit to most users are the 
exception rather than the rule, so this may a corner case I would like 
to see sk98lin back in the kernel, for a while I can build my own 
kernels and patch it in, but until other drivers are drop-in, I probably 
won't change.

Separate but related: why keep skge and sky2? Are we going through this 
again in a year? Is the benefit worth the effort?

Hope some of this is helpful.

-- 
bill davidsen <davidsen@tmr.com>
  CTO TMR Associates, Inc
  Doing interesting things with small computers since 1979

