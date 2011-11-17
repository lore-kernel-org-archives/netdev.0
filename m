From: Ivan Zahariev <famzah@icdsoft.com>
Subject: Re: Unable to flush ICMP redirect routes in kernel 3.0+
Date: Thu, 17 Nov 2011 10:10:08 +0200
Message-ID: <4EC4C160.6010804@icdsoft.com>
References: <4EC2CA52.6020104@icdsoft.com> <1321391355.2602.0.camel@edumazet-laptop> <4EC439F2.3080809@icdsoft.com> <20111116223330.08de9e52@asterix.rh>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from icdsoft.com ([64.14.68.165]:47011 "EHLO us.icdsoft.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755872Ab1KQIKR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Nov 2011 03:10:17 -0500
In-Reply-To: <20111116223330.08de9e52@asterix.rh>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17.11.2011 =D0=B3. 02:33 =D1=87., Flavio Leitner wrote:
> On Thu, 17 Nov 2011 00:32:18 +0200
> Ivan Zahariev<famzah@icdsoft.com>  wrote:
>
>> On 11/15/2011 11:09 PM, Eric Dumazet wrote:
>>> Le mardi 15 novembre 2011 =C3=A0 22:23 +0200, Ivan Zahariev a =C3=A9=
crit :
>>>> Hello,
>>>>
>>>> We have changed nothing in our network infrastructure but only
>>>> upgraded from Linux kernel 2.6.36.2 to 3.0.3. Here is the problem
>>>> we are experiencing:
>>>>
>>>> ICMP redirected routes are cached forever, and they can be cleared
>>>> only by a reboot.
>>>>
>> ### (bug #1) even though we flushed the route cache, the<redirected>
>> route resurrects from somewhere; even without making any TCP request=
s
>> ### this time what "ip" returns is consistent with the real
>> (incorrect) routing behavior of machine5
>> root@machine5:~# ip route flush cache
>> root@machine5:~# ip route list cache match 8.8.4.4
>> root@machine5:~# ip route get 8.8.4.4
>> 8.8.4.4 via 192.168.0.120 dev eth0  src 192.168.0.244
>>       cache<redirected>   ipid 0x303a
>>
>> ### only a reboot clears the cached<redirected>  routes
> IIRC, the cache flush doesn't affect the inetpeer where the
> redirected gateway is now stored, so even after flushing the
> route cache, the inetpeer will restore the old info later.
>
> fbl
OK, I guess my questions now are:
* How to flush the inetpeer (redirected cache info) without having to=20
reboot the machine?
* Why "ip route" returns an incorrect route; example:

### (bug #2) what "ip route" returns is inconsistent, because we are=20
using the <redirected> route 192.168.0.120 in reality
### note that the count of the route lines increased with one
root@machine5:~# ip route list cache match 8.8.4.4
8.8.4.4 from 192.168.0.244 tos lowdelay via 192.168.0.8 dev eth0
     cache  ipid 0x303a
8.8.4.4 tos lowdelay via 192.168.0.8 dev eth0  src 192.168.0.244
     cache  ipid 0x303a
8.8.4.4 via 192.168.0.8 dev eth0  src 192.168.0.244
     cache
8.8.4.4 from 192.168.0.244 tos lowdelay via 192.168.0.8 dev eth0
     cache  ipid 0x303a

### After "ip route flush cache", the output of "ip route" gets=20
consistent with the real routing behavior of machine5
root@machine5:~# ip route flush cache
root@machine5:~# ip route list cache match 8.8.4.4
root@machine5:~# ip route get 8.8.4.4
8.8.4.4 via 192.168.0.120 dev eth0  src 192.168.0.244
     cache <redirected>  ipid 0x303a

Thanks.
--Ivan
