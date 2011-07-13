From: Chris Friesen <chris.friesen@genband.com>
Subject: Re: any way to let host act as TCP server OR client on same IP/port?
Date: Wed, 13 Jul 2011 16:28:11 -0600
Message-ID: <4E1E1BFB.7040801@genband.com>
References: <4E1DC83C.3020506@genband.com>	<1310579520.2509.17.camel@edumazet-laptop>	<4E1DDE62.3080503@hp.com> <4E1DEEF9.7040901@genband.com> <4E1E01BF.3040201@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og102.obsmtp.com ([64.18.2.157]:51463 "EHLO
	exprod7og102.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750877Ab1GMW20 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jul 2011 18:28:26 -0400
In-Reply-To: <4E1E01BF.3040201@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/13/2011 02:36 PM, Rick Jones wrote:
>>>
>>> I was thinking the same thing, but it appears to not work under:
>>
>> <snip>
>>
>>> if (bind(listener,
>>> (struct sockaddr *)&me,
>>> sizeof(me))< 0) {
>>> perror("bind listener");
>>> exit(-1);
>>> }
>>>
>>> if (listen(listener,128)< 0) {
>>> perror("listen listener");
>>> exit(-1);
>>> }
>>>
>>> /* connect something to it */
>>> if (connect(client,(struct sockaddr *)&me,sizeof(me))< 0) {
>>> perror("connect client");
>>> exit(-1);
>>
>> In our case we don't need to actually be connected, just be listening
>> and ready to either accept() a connection or connect() to someone else.
>
> If one calls listen() against a socket, TCP connections can be
> established at any time, before the accept() calls are made. As for what
> might happen when one calls connect() on a listen socket when there are
> queued connections awaiting accept() I've no idea.

In Linux at least it appears that you aren't allowed to call listen() 
and then connect().  See below, however.

> If your application's sematics are OK with pending connections being
> dumped, and there is no issue with something else binding to IP,port and
> putting it into the LISTEN state, and if I've read between the lines of
> what you've written correctly, you could simply close() the listen
> socket and create a fresh socket with which to do the connect()?

Ah, of course.  It actually looks like a shutdown() might be sufficient 
to reset the state of the socket enough to allow me to then call 
connect() without needing to create a new socket and bind it.

I'll see what the application guys say.

Thanks,
Chris


-- 
Chris Friesen
Software Developer
GENBAND
chris.friesen@genband.com
www.genband.com
