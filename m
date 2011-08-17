From: Pascal Hambourg <pascal@plouf.fr.eu.org>
Subject: Re: Linux vs FreeBSD Which is correct.
Date: Wed, 17 Aug 2011 22:15:52 +0200
Message-ID: <4E4C2178.1000809@plouf.fr.eu.org>
References: <4E4BF456.9000807@earthlink.net> <201108172017.48683.remi@remlab.net> <4E4C1A00.80207@earthlink.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?ISO-8859-15?Q?R=E9mi_Denis-Courmont?= <remi@remlab.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: sclark46@earthlink.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from poutre.nerim.net ([62.4.16.124]:62385 "EHLO poutre.nerim.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751727Ab1HQUXb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Aug 2011 16:23:31 -0400
In-Reply-To: <4E4C1A00.80207@earthlink.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

Stephen Clark a =E9crit :
> On 08/17/2011 01:17 PM, R=E9mi Denis-Courmont wrote:
>> Le mercredi 17 ao=FBt 2011 20:03:18 Stephen Clark, vous avez =E9crit=
 :
>>   =20
>>> I have run into a situation where if I ping our HQ the response com=
es
>>> back on a different
>>> interface than what the request went out on. FreeBSD is happy and s=
ays
>>> it got the response,
>>> Linux is not and gives no indication it got a response.
>>>
>>> So is FreeBSD wrong or is Linux wrong?

Neither is right or wrong. It partly depends whether you want to enforc=
e
so-called "weak" or "strong" host model.

>> Most distributions enable reverse path filtering by default.
>> It can be disabled:
>> # echo -n 0>  /proc/sys/net/ipv4/conf/all/rp_filter
>>
>> But you should probably fix the configuration instead (e.g. /etc/sys=
ctl.conf).
>>   =20
> Sorry that didn't help either.

Since some kernel version the logic of this sysctl has changed from
AND(all, $interface) to MAX(all, $interface). So you must set
net/ipv4/conf/$interface/rp_filter to 0 too to disable it.
Or set net/ipv4/conf/all/rp_filter to 2 to make it weaker.
