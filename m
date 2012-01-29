From: Simon Chen <simonchennj@gmail.com>
Subject: Re: increase the number of routing tables
Date: Sat, 28 Jan 2012 23:20:33 -0500
Message-ID: <CANj2EbdFc33ciZ02ZCF7=3sY1XTbCLrdfu4Mp_vLp4N94xu5Cw@mail.gmail.com>
References: <CANj2EbfR0cBaBd+t1yCZyErRpVzSC00DZohvtyazK8_9bv2aEQ@mail.gmail.com>
	<1327804887.2805.20.camel@edumazet-laptop>
	<4F24B2E9.3010600@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:41774 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752928Ab2A2EUe convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Jan 2012 23:20:34 -0500
Received: by wgbed3 with SMTP id ed3so3383313wgb.1
        for <netdev@vger.kernel.org>; Sat, 28 Jan 2012 20:20:33 -0800 (PST)
In-Reply-To: <4F24B2E9.3010600@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks...

Here says 252 routing tables top... maybe that's too old:
http://linux-ip.net/html/routing-tables.html

I wonder if we can use a trie-tree for "ip rule" - linear evaluation
does not sound too good. But I'll be using a ton of iptables rules as
well, and I believe those are linear evaluation too :-(

On Sat, Jan 28, 2012 at 9:46 PM, Ben Greear <greearb@candelatech.com> w=
rote:
> On 01/28/2012 06:41 PM, Eric Dumazet wrote:
>>
>> Le samedi 28 janvier 2012 =E0 21:20 -0500, Simon Chen a =E9crit :
>>>
>>> Hey folks,
>>>
>>> To my limited knowledge, Linux currently supports 256 (255?) routin=
g
>>> tables defined in /etc/iproute2/rt_tables.
>>>
>>> Is there a way to increase this number to something much larger? Ar=
e
>>> there performance/scalability concerns there? I am trying to have
>>> customized routing table for each IP address (using "ip rule add fr=
om
>>> xxx table yyy"). I am not sure exactly how many IPs I'll handle, bu=
t
>>> certainly more than 255...
>>>
>>
>> Its is possible, but probably not scalable.
>
>
> I've run with a few thousand routing tables and probably 5000 or so
> rules. =A0It seems to run OK....
>
>
>> You really should not have too many "ip rule" entries, since they ar=
e
>> evaluated linearly.
>
>
> For every packet, or maybe just until conn-track gets an entry
> for the connection?
>
> Thanks,
> Ben
>
>
> --
> Ben Greear <greearb@candelatech.com>
> Candela Technologies Inc =A0http://www.candelatech.com
