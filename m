From: John Haxby <john.haxby@oracle.com>
Subject: Re: [PATCH 1/2] netfilter: xtables: inclusion of xt_SYSRQ
Date: Wed, 28 Apr 2010 15:43:30 +0100
Message-ID: <4BD84992.5030909@oracle.com>
References: <1271845618-28569-1-git-send-email-jengelh@medozas.de> <1271845618-28569-2-git-send-email-jengelh@medozas.de> <4BCEF6B4.8090105@trash.net> <alpine.LSU.2.01.1004211506280.10840@obet.zrqbmnf.qr> <4BCEFACC.7020804@trash.net> <alpine.LSU.2.01.1004211533410.21020@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:54625 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750952Ab0D1Onz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Apr 2010 10:43:55 -0400
In-Reply-To: <alpine.LSU.2.01.1004211533410.21020@obet.zrqbmnf.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 21/04/10 14:35, Jan Engelhardt wrote:
> On Wednesday 2010-04-21 15:17, Patrick McHardy wrote:
>    
>> Jan Engelhardt wrote:
>>      
>>> On Wednesday 2010-04-21 14:59, Patrick McHardy wrote:
>>>
>>>        
>>>> Jan Engelhardt wrote:
>>>>          
>>>>> The SYSRQ target will allow to remotely invoke sysrq on the local
>>>>> machine. Authentication is by means of a pre-shared key that can
>>>>> either be transmitted plaintext or digest-secured.
>>>>>            
>>>> I really think this is pushing what netfilter is meant for a bit
>>>> far. Its basically abusing the firewall ruleset to offer a network
>>>> service.
>>>>
>>>> I can see that its useful to have this in the kernel instead of
>>>> userspace, but why isn't this implemented as a stand-alone module?
>>>> That seems like a better design to me and also makes it more useful
>>>> by not depending on netfilter.
>>>>          
>>> That sort of diverts from the earlier what-seemed-to-be-consensus.
>>>
>>> Oh well, I would not mind holding the single commit up as long as the
>>> rest isn't blocked too :-)
>>>        
>> Then lets skip this one for now.
>>      
> Well you raised the concern before -- namely that kdboe would have
> the very same feature. And yet, kdboe was not part of the kernel.
> Neither is the magical stand-alone module.
> I really prefer to have it in rather than out, because I know
> that's going to mess up maintenance-here-and-there. I'm already
> having a big time with xtables-addons that still carries
> xt_condition and SYSRQ for a while, and it does have some different
> code lines than the kernel copy.
>    

I have to agree with Jan here, but I'd like to raise some additional points.

kdboe (or kgdboe) isn't part of the kernel and I don't think it 
necessarily fits all the use cases for xt_SYSRQ.  The one I have in mind 
is where there is a non-kernel hacker whose machine has got into 
trouble.  The poor harrassed sys admin (in this case) has configured 
netconsole and knows that sysrq-t and sysrq-m are useful as a first 
attempt at passing useful information to someone who knows what might be 
going on and that sysrq-c to get a crash dump will also be useful.   
(This represents quite a few of the better sys admins that I come 
across.)   xt_SYSRQ is likewise easy to set up and easy to use.   It's 
true that k(g)dboe would provide this kind of information provided that 
the debuginfo was present on the target machine and the environment was 
such that any sort of debugging over netconsole was sufficiently secure 
... (is it at least as secure as the xt_SYSRQ controls?)

I was running over the design of a standalone module in my head on the 
way in this morning.   It seems fairly straightforward, but as I started 
adding in necessary requirements like limited IP addresses (which I know 
are not actually secure), limited interfaces (which are more secure in a 
controlled physical environment), user-space control and so on the more 
it was sounding as though it would just be a cut-down iptables.   And 
then, of course, that begs the question "why don't you leave all that 
extra stuff to iptables?"

My own interest in getting xt_SYSRQ into the mainline kernel is that it 
would then be easier to get it accepted in production kernels where it 
would make the poor beleaguered sys admin's life a little easier.  That 
is, _some_ useful information or even a crash dump could be extracted 
from the machine before it's big red button time.

jch
