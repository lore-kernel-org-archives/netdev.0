From: Bill Davidsen <davidsen@tmr.com>
Subject: Re: [RFD] iptables: mangle table obsoletes filter table
Date: Tue, 23 Oct 2007 18:27:58 -0400
Message-ID: <471E756E.3070008@tmr.com>
References: <200710120031.42805.a1426z@gawab.com> <200710200640.02012.a1426z@gawab.com> <26556.1192855654@turing-police.cc.vt.edu> <200710210731.58959.a1426z@gawab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Valdis.Kletnieks@vt.edu, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	linux-net@vger.kernel.org, linux-kernel@vger.kernel.org
To: Al Boldi <a1426z@gawab.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <200710210731.58959.a1426z@gawab.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Al Boldi wrote:
> Valdis.Kletnieks@vt.edu wrote:
>> On Sat, 20 Oct 2007 06:40:02 +0300, Al Boldi said:
>>> Sure, the idea was to mark the filter table obsolete as to make people
>>> start using the mangle table to do their filtering for new setups.  The
>>> filter table would then still be available for legacy/special setups. 
>>> But this would only be possible if we at least ported the REJECT target
>>> to mangle.
>> That's *half* the battle.  The other half is explaining why I should move
>> from a perfectly functional setup that uses the filter table.  What gains
>> do I get from doing so?  What isn't working that I don't know about? etc?
>>
>> In other words - why do I want to move from filter to mangle?
> 
> This has already been explained in this thread; here it is again:
> 
> Al Boldi wrote:
>>>> The problem is that people think they are safe with the filter table,
>>>> when in fact they need the prerouting chain to seal things.  Right now
>>>> this is only possible in the mangle table.
>>> Why do they need PREROUTING?
>> Well, for example to stop any transient packets being forwarded.  You could 
>> probably hack around this using mark's, but you can't stop the implied
>> route lookup, unless you stop it in prerouting.
> 
> Basically, you have one big unintended gaping whole in your firewall, that 
> could easily be exploited for DoS attacks at the least, unless you put in 
> specific rules to limit this.
> 
Well... true enough on a small firewall machine with a really fast link, 
maybe. I like your point about efficiency better, it's more logical, 
like putting an ACCEPT of established connections before a lot of low 
probability rules. The only time I have seen rules actually bog a 
machine was when a major ISP sent out a customer "upgrade" with a bug 
which caused certain connections to be SYN-SYN/ACK-RST leaving half open 
sockets. They sent out 160k of them and the blocking list became very 
long as blocking rules were added.

> Plus, it's outrageously incorrect to accept invalid packets, just because 
> your filtering infrastructure can only reject packets after they have been 
> prerouted.
> 
As long as the filter table doesn't go away, sometimes things change 
after PREROUTING, like NAT, and additional rules must be used.

-- 
Bill Davidsen <davidsen@tmr.com>
   "We have more to fear from the bungling of the incompetent than from
the machinations of the wicked."  - from Slashdot
