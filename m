From: Charles Bearden <Charles.F.Bearden@uth.tmc.edu>
Subject: Re: TCP keepalives ignored by kernel when the contain timestamps
Date: Fri, 10 Jun 2011 13:00:02 -0500
Message-ID: <4DF25BA2.4040200@uth.tmc.edu>
References: <4DF0E638.2010506@uth.tmc.edu> <1307714177.4044.4.camel@edumazet-laptop> <4DF233CE.5020000@uth.tmc.edu> <4DF24154.3060505@uth.tmc.edu> <1307722621.4044.17.camel@edumazet-laptop> <4DF248C5.9050004@uth.tmc.edu> <1307724870.4044.20.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta3.uth.tmc.edu ([129.106.148.58]:31058 "EHLO mta3.uth.tmc.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757477Ab1FJSAD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Jun 2011 14:00:03 -0400
In-Reply-To: <1307724870.4044.20.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/10/2011 11:54 AM, Eric Dumazet wrote:
> Le vendredi 10 juin 2011 =C3=A0 11:39 -0500, Charles Bearden a =C3=A9=
crit :
>> On 06/10/2011 11:17 AM, Eric Dumazet wrote:
>>> Le vendredi 10 juin 2011 =C3=A0 11:07 -0500, Charles Bearden a =C3=A9=
crit :
>>>
>>>> You are correct: the checksums in the keepalives are broken, thoug=
h they are
>>>> correct in the other segments from the Win2008 server. I have upda=
ted the pastes
>>>> linked to above with 'tcpdump -v' output. I apologize for missing =
that problem
>>>> the first time around.
>>>
>>> Hmm, maybe its OK : If checksums are offloaded to NIC, tcpdump 'lie=
s'
>>> telling checksum is not OK, since tcpdump get a copy of the packet
>>> before being handled by the NIC.
>>>
>>> You should take a tcpdump on the receiving machine (the machine tha=
t
>>> apparently doesnt react to the keepalive probes)
>>
>> I should have made this clear before: these dumps were captured on t=
he machine
>> that is ignoring the keepalives ("Ubuntu.host" in the dumps) from th=
e other host
>> ("Win200[38].host" in the dumps). If I understand tcp checksum offlo=
ading
>> correctly, it wouldn't play a role here.
>>
>
> OK, thanks.
>
> I am curious, could you check the payload byte included in the keepal=
ive
> probes has the value of last sent byte on the session ?
>
> (linux send keepalive probes with no data, so implementing this
> 'feature' would need to keep track of this value in tcp socket)

Each keepalive from the Win2008 machine has a 1-byte payload 0x00. The =
last byte=20
of the last packet with a payload before that from the Win2008 host (at=
=20
14:40:18.166394 in the paste) is also 0x00. Is that what you were askin=
g about?

