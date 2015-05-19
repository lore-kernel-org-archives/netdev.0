From: Patrick Simmons <linuxrocks123@netscape.net>
Subject: Re: [PATCH] Experimental new bonding driver mode=batman
Date: Tue, 19 May 2015 04:29:45 -0400
Message-ID: <555AF479.7000603@netscape.net>
References: <555AD3A7.7050202@netscape.net> <20150519074941.GB17391@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from omr-m4.mx.aol.com ([64.12.226.25]:43350 "EHLO omr-m4.mx.aol.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753139AbbESIfr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 May 2015 04:35:47 -0400
In-Reply-To: <20150519074941.GB17391@unicorn.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/19/2015 03:49 AM, Michal Kubecek wrote:
> On Tue, May 19, 2015 at 02:09:43AM -0400, Patrick Simmons wrote:
>>
>> I've written a new mode for the kernel bonding driver.  It's similar to
>> the round-robin mode, but it keeps statistics on TCP resends so as to
>> favor slave devices with more bandwidth when choosing where to send
>> packets.  I've tested it on two laptops using WiFi/Ethernet and it seems
>> to work okay, but it should be considered experimental.
>
> A description of how is the mode supposed to work would be definitely
> helpful.
>

Rationale: It's helpful for cases where the slave devices have 
significantly different or varying bandwidth.  The reason I wrote it is 
to bond powerline networking and wireless networking adapters into a 
single interface for use with connecting to a MythTV server.  Neither of 
these systems is particularly reliable with bandwidth, but mode=batman 
can adaptively figure out which network has more available bandwidth at 
any given moment.  This is better than mode=round-robin which always 
balances everything 50/50.

Regarding your analysis, I appreciate your comments, and I know it's 
rough, but I'm sorry to say I'm not really interested in doing much to 
improve its polish past where it is.  If it fails some way when I try to 
deploy it, then I'll fix that, and maybe I'll play around with the 
balancing heuristics, but the code quality is what it is unless someone 
else wants to improve it.  I would fix the indentation if that would 
make it acceptable for you to merge it, but not much more.  My argument 
for merging it is basically "it doesn't do anything unless you pass 
mode=batman, so what's the harm?".

So, if you guys decide you don't want to merge it because of the global 
spinlock etc., that's cool and I understand, but I thought I should at 
least post to this list so you and any other potentially interested 
people know it exists.  Oh, and, if you're not going to merge it, please 
let me know so I can know post the patch to GitHub or somewhere.  And, 
if you could include a note in the comments at the top of bond_main.c or 
somewhere pointing people to the patch, I'd very much appreciate that. 
I don't want anyone else to have to endure hours of kernel rebuilds with 
KASAN enabled if they want this functionality :)

Cheers and have a good one!

--Patrick

-- 
If I'm not here, I've gone out to find myself.  If I get back before I 
return, please keep me here.
