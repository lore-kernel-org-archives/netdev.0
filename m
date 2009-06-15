From: =?UTF-8?B?UGF3ZcWCIFN0YXN6ZXdza2k=?= <pstaszewski@itcare.pl>
Subject: Re: iproute2 action/policer question
Date: Mon, 15 Jun 2009 18:09:57 +0200
Message-ID: <4A367255.5050604@itcare.pl>
References: <20090615111927.GA12316@ff.dom.local> <1245072728.3948.14.camel@dogo.mojatatu.com> <20090615145222.GA2767@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jamal <hadi@cyberus.ca>,
	Linux Network Development list <netdev@vger.kernel.org>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.iq.pl ([86.111.241.19]:49042 "EHLO smtp.iq.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754854AbZFOQJ4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Jun 2009 12:09:56 -0400
In-Reply-To: <20090615145222.GA2767@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski pisze:
> On Mon, Jun 15, 2009 at 09:32:08AM -0400, jamal wrote:
>   
>> On Mon, 2009-06-15 at 11:19 +0000, Jarek Poplawski wrote:
>>
>>     
>>>> This is only a sample but is not working
>>>>         
>> It does seem to be working!
>> How did you reach conclusion it wasnt working?
>>
>>     
>>>>         Action statistics:
>>>>         Sent 42351 bytes 110 pkt (dropped 0, overlimits 32 requeues 0)
>>>>         rate 0bit 0pps backlog 0b 0p requeues 0
>>>>         
>> 32 packets hit the policer - double check your parameters please to make
>> sure they are correct.
>>     
>
>   
Yes. packets hits policer but second action dont drop packets.

Second is that in policer there is action to "-j MARK" mark packet but 
where i can catch this mark ? in iptables mangle i make some rules to 
match mark and make LOG target like this:
but iptables rules catch nothing.

Chain PREROUTING (policy ACCEPT 19M packets, 19G bytes)
 pkts bytes target     prot opt in     out     source               
 destination
     0     0 LOG        all  --  *      *       0.0.0.0/0            
 0.0.0.0/0           mark match 0x1 LOG flags 0 level 4

Chain POSTROUTING (policy ACCEPT 11M packets, 17G bytes)
  pkts bytes target     prot opt in     out     source               
 destination
     0     0 LOG        all  --  *      *       0.0.0.0/0            
 0.0.0.0/0           mark match 0x1 LOG flags 0 level 4


version of tools:
iptables -V
iptables v1.4.2
tc -V
tc utility, iproute2-ss090324



> Actually, I wonder if these "dropped 0" are OK here if we expect
> dropping.
>
>   
>>> According to iproute2/doc/actions/actions_general mangle targets
>>> should work; and you could also try (if it doesn't work then probably
>>> it can't be used...;-)
>>>       
>> They should all be usable. If something crashes, there is a bug
>> somewhere.
>>
>>     
>>> But... I'm neither able to configure/compile it with the current
>>> iproute2/iptables, nor test it with distro's builds (Debian testing).
>>> After some checking I found iproute2 needs updating, because iptables
>>> changes API (xtables.h) virtually with every new version, so I don't
>>> even blame the ipt author or distro maintainer.
>>>
>>>       
>> We are hopefully getting stable there. Anything on debian lenny
>> should be working with iptables 1.4.3; i expect at most "one last
>> change" (famous last words) to break backward compat as iptables 
>> moves from version 1.4.3.
>>     
>
> I've tried debian squeeze (testing) with: iptables v1.4.3.2, iproute2
> -ss090324, and action ipt -j MARK doesn't work. AFAIK debian lenny
> (stable) uses 1.4.2. I've also tried debian rescue probably based on
> lenny (with iptables 1.4.2), and it seemed it didn't work yet (I'll
> re-check this). When you have something new I'd be glad for Cc.
>
> Thanks more than always Jamal,
> Jarek P.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>
>   

