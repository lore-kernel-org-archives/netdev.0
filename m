From: Martin Devera <devik@cdi.cz>
Subject: Re: Possible regression in HTB
Date: Thu, 09 Oct 2008 12:52:27 +0200
Message-ID: <48EDE26B.6040101@cdi.cz>
References: <48EB5A92.6010704@trash.net> <20081007220022.GA2664@ami.dom.local> <20081008002153.GL12021@verge.net.au> <48EBFF5E.1090902@trash.net> <48EC0190.7040804@trash.net> <48EC6286.1030202@cdi.cz> <20081008085325.GF4174@ff.dom.local> <48EC8FDD.5030507@cdi.cz> <20081009010957.GB6342@verge.net.au> <48EDA339.3040706@cdi.cz> <20081009095600.GB4159@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Simon Horman <horms@verge.net.au>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.wifcom.cz ([89.185.251.8]:36330 "EHLO wifcom.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753872AbYJIKwh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Oct 2008 06:52:37 -0400
In-Reply-To: <20081009095600.GB4159@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> On Thu, Oct 09, 2008 at 08:22:49AM +0200, Martin Devera wrote:
>>>> Simon, can you try to these things (separately):
>>>> a/ increase quantum to the first class (say 10x)
>>> Hi Martin,
>>>
>>> Do you mean increase r2q ? If so, here are some results
>> no, no, add rather ... "quantum 50000" to the first class only
>> r2q affects computation for all classes
> 
> Yes, it's a half-documented parameter: not in the man, but e.g. here:
> tc class add htb help
> 
> BTW, I wonder if better priority/quantum doesn't actually harm here.
> When HTB lends the rate the first class here is always served at the
> beginning. And if it's over the hardware limit, this class's packets
> are waiting. Other classes get their chunks later, probably after the
> card did some cleaning, so they may never have to wait at this
> situation. So, maybe it would be interesting to try this other way:
> lower priority of the first class with a prio param e.g. 1?

It starts to seem too complex to me (too many races related hypotheses).
The original intent was to investigate possibly corrupted drr pointer,
but just now I think the only way is to stuff enough debug code into
htb and try myself...
It will be probable faster - once I find time to do it.
