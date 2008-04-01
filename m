From: Bernard Pidoux <bpidoux@free.fr>
Subject: Re: [AX25] kernel panic
Date: Tue, 01 Apr 2008 22:37:02 +0200
Message-ID: <47F29CEE.10307@free.fr>
References: <47E68CA1.2040904@free.fr> <20080324205104.GA3721@ami.dom.local> <47E8FCE2.6000308@free.fr> <20080326183538.GA14266@ami.dom.local> <20080328120721.GA11060@ami.dom.local> <47EE3040.3050208@free.fr> <20080329122452.GB3407@ami.dom.local> <47EE38BA.9090500@free.fr> <20080329130451.GC3407@ami.dom.local> <47EF6479.7030702@free.fr> <20080330115958.GA4975@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2@o2.pl>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Ralf Baechle DL5RB <ralf@linux-mips.org>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5-g19.free.fr ([212.27.42.35]:43165 "EHLO smtp5-g19.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756732AbYDBABY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Apr 2008 20:01:24 -0400
In-Reply-To: <20080330115958.GA4975@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Jarek Poplawski wrote:
> On Sun, Mar 30, 2008 at 11:59:21AM +0200, Bernard Pidoux wrote:
> ...
>> I would not be surprised if ROSE was involved as, remember, I first  
>> found the bug when I closed an AX25 session established through a level  
>> 3 ROSE network (FPAC) via AXUDP link (ax25ipd). As I said in my first  
>> bug report, the bug is not triggered when connecting locally or via AX25  
>> call through LAN. Thus ROSE level is involved.
>>
>> However, I guess that lower layer (AX25) should stand a possible error  
>> in the upper layer protocol (ROSE).
> 
> I think ROSE breaks some general rules here: bugs trigger in sock.c
> code when ROSE packets are destroyed after closing its sockets, but
> without proper information on this.
> 
>> ROSE is actually an AX25 packet routing protocol with only three byte  
>> offset added to AX25 frames (encapsulation). Of course it has its own  
>> bugs...
> 
> Probably... BTW, my today's patch adds some locking, so there is always
> some risk of a lockup or some new lockdep warning. And if accidentally
> it works, after testing with these debugging patches there would be
> needed later a test of this #5 alone, as well.
> 
> Thanks,
> Jarek P.
> 
> 


I did what you suggested and reversed your patches #2,#3 and #4 to 
verify that there was no system incompatibilities with the new locks you 
introduced into rose_release().

Patch #1 has also been removed on another machine running a 64 bit Core2 
duo CPU.


Three Linux boxes have been are running for more than 24 hours now with 
only patch #5. They handled a lot of AX25 connections with no problems.

Thus, we can reasonably expect that things are going to stay stable.

If you want to commit patch#5 I will sustain it very much.

I hope that it will be accepted quickly in order to make a coherent 
system with AX25 patches already applied or not yet applied (if any).

Thank you very much Jarek for this very nice job.


Best regards,


Bernard Pidoux,
F6BVP

