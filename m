From: John Haxby <john.haxby@oracle.com>
Subject: Re: [PATCH 1/2] netfilter: xtables: inclusion of xt_SYSRQ
Date: Wed, 28 Apr 2010 15:54:27 +0100
Message-ID: <4BD84C23.2000301@oracle.com>
References: <1271845618-28569-1-git-send-email-jengelh@medozas.de> <1271845618-28569-2-git-send-email-jengelh@medozas.de> <4BCEF6B4.8090105@trash.net> <alpine.LSU.2.01.1004211506280.10840@obet.zrqbmnf.qr> <4BCEFACC.7020804@trash.net> <alpine.LSU.2.01.1004211533410.21020@obet.zrqbmnf.qr> <4BD84992.5030909@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:60470 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754784Ab0D1O4f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Apr 2010 10:56:35 -0400
In-Reply-To: <4BD84992.5030909@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 28/04/10 15:43, John Haxby wrote:
>
> kdboe (or kgdboe) isn't part of the kernel and I don't think it 
> necessarily fits all the use cases for xt_SYSRQ.  The one I have in 
> mind is where there is a non-kernel hacker whose machine has got into 
> trouble.  The poor harrassed sys admin (in this case) has configured 
> netconsole and knows that sysrq-t and sysrq-m are useful as a first 
> attempt at passing useful information to someone who knows what might 
> be going on and that sysrq-c to get a crash dump will also be 
> useful.   (This represents quite a few of the better sys admins that I 
> come across.)   xt_SYSRQ is likewise easy to set up and easy to use.   
> It's true that k(g)dboe would provide this kind of information 
> provided that the debuginfo was present on the target machine and the 
> environment was such that any sort of debugging over netconsole was 
> sufficiently secure ... (is it at least as secure as the xt_SYSRQ 
> controls?)
>

I really must read what I've written more carefully.   I should have 
gone on to say that I don't see that k(g)dboe will be viable in this use 
case although for someone actually debugging a kernel on a machine that 
they have access to xt_SYSRQ leaves an awful lot to be desired :-)   But 
that isn't the common use-case I see -- the one I see is where the sys 
admins used to have a "crash trolley" which was a console and PS/2 
keyboard which they could plug into a machine to get some information, 
but as many rack machines no longer have anything PS/2 and USB hot plug 
is unlikely to work on a sick machine we need a sufficiently light 
mechanism that it will work in most cases (xt_SYSRQ is careful to 
pre-allocate most of the resources it will need).


And then I should have said that moving on to the possibility of a 
standalone module and that ...
> I was running over the design of a standalone module in my head on the 
> way in this morning.   It seems fairly straightforward, but as I 
> started adding in necessary requirements like limited IP addresses 
> (which I know are not actually secure), limited interfaces (which are 
> more secure in a controlled physical environment), user-space control 
> and so on the more it was sounding as though it would just be a 
> cut-down iptables.   And then, of course, that begs the question "why 
> don't you leave all that extra stuff to iptables?"

So unless I'm missing something obvious and different, I don't see that 
a standalone module is going to be lightweight enough to be acceptable.


Sorry for not making filling this parts in earlier.

jch

