From: Chris Friesen <chris.friesen@genband.com>
Subject: Re: any way to let host act as TCP server OR client on same IP/port?
Date: Thu, 14 Jul 2011 08:55:01 -0600
Message-ID: <4E1F0345.8020108@genband.com>
References: <4E1DC83C.3020506@genband.com> <1310579520.2509.17.camel@edumazet-laptop> <4E1DDE62.3080503@hp.com> <4E1DEEF9.7040901@genband.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og114.obsmtp.com ([64.18.2.215]:58600 "EHLO
	exprod7og114.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754769Ab1GNOz4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jul 2011 10:55:56 -0400
In-Reply-To: <4E1DEEF9.7040901@genband.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/13/2011 01:16 PM, Chris Friesen wrote:
> On 07/13/2011 12:05 PM, Rick Jones wrote:
>> On 07/13/2011 10:52 AM, Eric Dumazet wrote:
>>> Le mercredi 13 juillet 2011 =E0 10:30 -0600, Chris Friesen a =E9cri=
t :
>>>> I've been asked an interesting question about TCP. We have some pe=
ople
>>>> that want to set up a TCP socket that can listen for connections o=
n a
>>>> given IP/port, but also initiate connections from that same IP/por=
t.
>>>> (Only one at a time, of course.)
>>>>
>>>> The TCP state machine seems to allow this (moving from LISTEN to
>>>> SYN_SENT) but it's not a normal transition.
>>>>
>>>> Is there any way to do this using the socket API?
>>>>
>>>> I thought up a hack whereby we could use NFQUEUE to detect an inco=
ming
>>>> SYN and delay it while we call listen() on the socket. Is there an=
y
>>>> better way to do this?
>>>
>>> Could you try SO_REUSEADDR, on both listener and connect attempt ?
>>
>> I was thinking the same thing, but it appears to not work under:


> In our case we don't need to actually be connected, just be listening
> and ready to either accept() a connection or connect() to someone els=
e.

It turns out that the application people really do want the server side=
=20
to be able to listen() at the same time as calling connect() from the=20
same address/port, so Rick's testcase was accurate.

It would be interesting if linux were to allow this behaviour.  It=20
doesn't seem to violate any specs, since we could still return an error=
=20
if we try to connect() to an address that is already connected to us.

Chris


--=20
Chris Friesen
Software Developer
GENBAND
chris.friesen@genband.com
www.genband.com
