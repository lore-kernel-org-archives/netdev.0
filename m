From: Patrick McHardy <kaber@trash.net>
Subject: Re: Passive OS fingerprinting.
Date: Tue, 01 Jul 2008 15:41:58 +0200
Message-ID: <486A3426.3000807@trash.net>
References: <20080701113927.GA16343@2ka.mipt.ru> <486A1AC7.9020706@trash.net> <20080701120320.GA9412@2ka.mipt.ru> <486A2487.2010303@trash.net> <20080701130835.GA29223@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20080701130835.GA29223@2ka.mipt.ru>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov wrote:
> On Tue, Jul 01, 2008 at 02:35:19PM +0200, Patrick McHardy (kaber@trash.net) wrote:
>   
>>>> My two main objections are that this only works for TCP and
>>>> can be trivially evaded. What use cases does it have?
>>>>         
>>> Yes, it is TCP specific module.
>>>       
>> What about the use cases? I certainly like the idea you suggest in
>> your blog ("Ever dreamt to block all Linux users in your network
>> from accessing internet and allow full bandwidth to Windows worm?")
>> :) But something this easy to evade doesn't seem to provide a real
>> benefit for a firewall.
>>     
>
> Actually worm detection is one of the use cases - I was told about
> successful installations several years ago.
>   

How does that work? I assume in combination with some kind of
rate-limit?

>>>> I'm also wondering whether this couldn't be implemented
>>>> using the u32 match.
>>>>         
>>> I'm not sure it is that simple. OSF uses common rules database
>>> shared with OpenBSD (and other *BSDs as well), so converting it into u32
>>> match would require noticeble efforts. But in theory it is probably
>>> doable.
>>>       
>> This would be preferrable in my opinion since they both allow
>> programmable filters, but u32 appears to be more flexible. I'm
>> very reluctant to add new iptables modules that don't increase
>> expressiveness or provide other clear benefits since we already
>> have an insane amount of modules.
>>     
>
> OSF does increase expressiveness! :)
> '--genre Linux' is much more clear than... Do you want me to at least
> roughly draw mathing rules enciphered in u32 format?
>
> I agree that matching can be done with u32 (even private OSF TTL games),
> but it will much much much more ugly than simple module.
>
> I am also not sure OSF should live in kernel, but what it does it does
> good and there is no simple way to do the same with existing
> functionality. It is possible, but not simple, and definitely not
> trivial for administrator :)
>   

I don't like the current way such things are implemented in iptables
(have all logic in the kernel instead of just providing a mechanism
for implementing it in userspace and presenting a nice view to the
administrator). Thats not your fault of course and your module is
also not the first one to do this.

Unfortunately its most likely not possible to convince me to like
this, so lets just say that I'm fine with merging it if someone
speaks up in favour of it :)

>>> Also I do not know why we want to remove connector in favour of
>>> genetlink, since the former is much simpler to work with. Connector
>>> logging is optional in OSF.
>>>       
>> I'm not sure if we want to, but they appear to provide similar
>> functionality and connector only has a single user in the tree
>> so far. But thats a different discussion, for netfilter related
>> things nfnetlink should be used.
>>     
>
> IIRC there are at least threee: w1, various accountings and uvesafb.
> And I authored only the first :)
>
> There was no nfnetlink either 5 years ago, when OSF was created,
> this release is just subsequent update to the project.
> At some moment OSF shared netlink group with ulog, but it was
> considered harmful, so I dropped support. Netlink usage is
> rather trivial: it just sends information about matched packt to
> userspace, so it can block it on its own, rise a message in the window
> or perform some other steps. Nothing exceptionally complex :)
>   

Yes, but I don't want to add another interface netfilter userspace
has to know about. It should either use nfnetlink and remove the proc
interface, or remove the connector interface and use proc.
Preferrably the former.

