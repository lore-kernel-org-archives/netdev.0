From: Ben Greear <greearb@candelatech.com>
Subject: Re: iputils: ping -I <iface>
Date: Fri, 30 Nov 2012 11:11:14 -0800
Message-ID: <50B904D2.5030502@candelatech.com>
References: <50B76D5B.8010804@redhat.com> <50B7BC0F.6000709@candelatech.com> <50B84CCB.7000502@redhat.com> <50B90326.2010302@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jan Synacek <jsynacek@redhat.com>, netdev@vger.kernel.org
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:37843 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S2993005Ab2K3TLZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Nov 2012 14:11:25 -0500
In-Reply-To: <50B90326.2010302@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/30/2012 11:04 AM, YOSHIFUJI Hideaki wrote:
> (2012=E5=B9=B411=E6=9C=8830=E6=97=A5 15:06), Jan Synacek wrote:
>> On 11/29/2012 08:48 PM, Ben Greear wrote:
>>> On 11/29/2012 06:12 AM, Jan Synacek wrote:
>>>> Hello,
>>>>
>>>> There seems to be a bug(?) when calling ping with -I lo:
>>>>
>>>> $ ping -I lo kernel.org
>>>>
>>>> PING kernel.org (149.20.4.69) from 192.168.1.10 lo: 56(84) bytes o=
f data.
>>>> ^C
>>>>
>>>> Note that 192.168.1.10 is my primary interface's address (em1). Ho=
wever, no
>>>> replies are coming back.
>>>>
>>>> $ ping -I em1 kernel.org
>>>>
>>>> PING kernel.org (149.20.4.69) from 192.168.1.10 em1: 56(84) bytes =
of data.
>>>> 64 bytes from pub2.kernel.org (149.20.4.69): icmp_seq=3D1 ttl=3D42=
 time=3D202 ms
>>>> 64 bytes from pub2.kernel.org (149.20.4.69): icmp_seq=3D2 ttl=3D42=
 time=3D187 ms
>>>> ^C
>>>>
>>>> Works as expected.
>>>>
>>>> I know that binding to loopback probably doesn't make much sense, =
but I think
>>>> that ping should be able to cope with that.
>>>
>>> I think it would be wrong if ping worked as you suggest.  Binding t=
o an
>>> interface means use that interface as the source of your packets, a=
nd having
>>> it bind hard helps when using systems with multiple NICs on same su=
bnet
>>> (or possibly, same IP).
>>
>> I just wanted to point out that if I call ping with -I lo, its 'from=
' address is
>> wrong (in my case 192.168.1.10) and nothing happens (that's, I guess=
, expected
>> if it really bound to loopback). If I call ping with the -I <the sam=
e address>
>> or -I em1 (the same address again), it works as expected. I'm sorry =
if I wasn't
>> clear enough.
>>
>>>
>>>> Also, it would be nice to mention the difference between -I <ip> a=
nd -I <iface>
>>>> in the manpage.
>>>
>>> In my opinion, -I <iface> should use SO_BINDTODEVICE, but at least =
in
>>> older versions of ping it did not.
>>
>> Ping does use SO_BINDTODEVICE.
>
> So far, -I device is related to source address selection (using
> SO_BINDTODEVICE) and outgoing device (using in_pktinfo).
> On the other hand, -I addr is, in fact, related to source
> address selection (and it is enfoced by bind), only.
>
> Something like this:
>
>         -I interface
>                interface is either an address, or an interface name. =
 If
>                interface is an address, it sets source address to
>                specified interface address.   If  interface
>                in  an  interface name, it tells the command to use th=
at
>                interface.  For ping6, when doing ping to a link-local
>                scope address, link specification (by the
>                '%'-notation in destination, or by this option) is
>                required.
>
> BUT, even with -I device, net/ipv4/dev_inet.c:inet_select_addr()
> may select an address from other interfaces, AFAIK).
>
> Should we check if the selected source address blongs to the actual
> device?

Maybe have -D <iface-name> and -P <source-address>
options?

Where -D uses SO_BINDTODEVICE, and -P binds to a source IP?

Would have to keep the -I logic similar to what it does now for
backwards compatibility...

Thanks,
Ben

>
> --yoshfuji
>


--=20
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
