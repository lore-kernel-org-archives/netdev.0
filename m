From: Stas Sergeev <stsp@list.ru>
Subject: Re: Q: bad routing table cache entries
Date: Wed, 13 Jan 2016 15:59:00 +0300
Message-ID: <56964A14.7080008@list.ru>
References: <5682665A.7090102@list.ru> <56951D1D.5080602@stressinduktion.org>
 <56952147.80201@stressinduktion.org> <569523C0.5040504@list.ru>
 <56952593.8040409@stressinduktion.org> <56952D01.6070204@list.ru>
 <56953059.1020506@list.ru> <569532A6.1070905@stressinduktion.org>
 <56953560.9050906@list.ru> <56953740.1090204@stressinduktion.org>
 <569538FD.2060200@list.ru> <56953C27.4030405@stressinduktion.org>
 <5695655A.60509@list.ru> <56957D95.1090307@stressinduktion.org>
 <569584CD.1040408@list.ru> <5695874A.2010600@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp51.i.mail.ru ([94.100.177.111]:45672 "EHLO smtp51.i.mail.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755217AbcAMM7H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jan 2016 07:59:07 -0500
In-Reply-To: <5695874A.2010600@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

13.01.2016 02:07, Hannes Frederic Sowa =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> Hi,
>=20
> On 12.01.2016 23:57, Stas Sergeev wrote:
>> 13.01.2016 01:26, Hannes Frederic Sowa =D0=BF=D0=B8=D1=88=D0=B5=D1=82=
:
>>> I didn't check a full featured setup but just did some dirty testin=
g
>>> with namespaces and I had correct arp request for the now to be
>>> assumed on-link router on the external veth.
>> I haven't checked anything with arp.
>> I set up tcpdump to only capture icmp.
>> What would you like me to check, could you please
>> give the detailed instructions?
>=20
> Check simply for arp traffic on the interface. arp requests should le=
ave your client and ask directly for the new router you got as next-hop=
=2E If it does not answer, there is the problem.
It does not answer:

tcpdump -vn -i eth0 arp host 192.168.10.202
tcpdump: listening on eth0, link-type EN10MB (Ethernet), capture size 6=
5535 bytes
15:38:23.334783 ARP, Ethernet (len 6), IPv4 (len 4), Request who-has 19=
2.168.0.1 tell 192.168.10.202, length 28
15:38:24.329949 ARP, Ethernet (len 6), IPv4 (len 4), Request who-has 19=
2.168.0.1 tell 192.168.10.202, length 28
15:38:25.329946 ARP, Ethernet (len 6), IPv4 (len 4), Request who-has 19=
2.168.0.1 tell 192.168.10.202, length 28
15:38:26.338987 ARP, Ethernet (len 6), IPv4 (len 4), Request who-has 19=
2.168.0.1 tell 192.168.10.202, length 28

This is what happens when I try to ping via the redirected route.
I wonder why should it answer. Suppose it has shared_media disabled,
should it answer into a different subnet even then?

>>>> If it is not - how can I even see that it exist? How to
>>>> list these redirect routes?
>>>
>>> Yeah, that might be a minor issue. The rt_cache procfs files are em=
pty
>>> since the deletion of the cache and we probably don't have an
>>> interface for next hop exceptions, I consider this todo. :) ip rout=
e
>>> get is your only hope right now.
>>>
>>> Anyway, seems like there are problems with redirect timeout somehow=
=2E I
>>> am investigating this.
>>>
>>>> I'd like to do some investigations, but this looks no
>>>> more than a black magic without a proper support
>>>> from tools, proper documentation, etc.
>>>
>>> Hmm, so far I think shared_media is behaving like it should,
>> No, unless you correct the documentation:
>> https://www.frozentux.net/ipsysctl-tutorial/chunkyhtml/theconfvariab=
les.html
>>
>> It says not what you say.
>> So this feature is essentially poorly (or wrongly) documented.
>=20
> I am sorry, but I have no access to this website. I just grepped arou=
nd in the Documentation/ directory of the kernel:
> <https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/tree=
/Documentation/networking/ip-sysctl.txt?id=3Drefs/tags/v4.4#n1014>
>=20
> It is correctly documented
With just a single-line description like this:
"Send(router) or accept(host) RFC1620 shared media redirects."

Isn't this too few for the feature that completely changes the
meaning of such fundamental things as the netmask is? IMHO the
books and articles should have been written before making it a default.=
 :)
And how about /proc/sys/net/ipv4/route/gc_interval, redirect_load,
redirect_number, redirect_silence? Are they documented at all?
I am trying to make the problematic event to trigger faster for
debugging, or make the cache to expire faster, but this all looks
completely undocumented and the intuitive guesses do not work.

>>> besides maybe it shouldn't be the default setting. Maybe someone wh=
o
>>> can remember why it is default could chime in?
>>>
>>>> And I suspect that shared_media is disabled on a 0.1
>>>> router, so I wonder if this can work at all, even if the node
>>>> is cured to do the right thing with those redirects.
>>>> In a nearby message David Miller says:
>>>
>>> Default is that shared_media is enabled,
>> On what OS, and since what version?
>>
>>> so the chances are relatively high that it is enabled if it is not
>>> turned off.
>> I don't even know what is there in a 0.1 router - maybe windows95,
>> who knows. You can't assume the latest linux kernel is everywhere.
>=20
> Looking into the kernel cvs history the change was done in 2000(!). W=
ould be pretty strange to find such an old kernel there.
The router at 192.168.0.1 may have some other OS, maybe freebsd.
You can't assume linux is everywhere.
