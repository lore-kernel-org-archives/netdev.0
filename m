From: Gilad Ben-Yossef <gilad@codefidence.com>
Subject: Re: [PATCH] [RFC] IPv4 TCP fails to send window scale option when
 window scale is zero
Date: Thu, 01 Oct 2009 11:39:43 +0200
Message-ID: <4AC478DF.2060401@codefidence.com>
References: <4AC22250.7060301@codefidence.com> <4AC241BA.8040608@gmail.com> <4AC2FA7C.6030901@codefidence.com> <4AC305BF.6080306@gmail.com> <alpine.DEB.2.00.0909301428140.13543@wel-95.cs.helsinki.fi> <4AC357D3.7080606@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Netdev <netdev@vger.kernel.org>, Ori Finkalman <ori@comsleep.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xenbox.codefidence.com ([92.48.73.16]:45029 "EHLO
	xenbox.codefidence.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750706AbZJAJjm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Oct 2009 05:39:42 -0400
In-Reply-To: <4AC357D3.7080606@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:

>
>>>
>>> Your version slows down the tcp_options_write() function, once per tx packet.
>>>       
>> Are you serious that anding would cost that much? :-/
>>     
>
> Not really :)
>   
LOL I was trying very hard to understand why you thought this was such 
an issue. My head was flying into all sorts of weird directions like 
cache effects and the like... ;-)

<snip>
> Yes, wscale 0 is RFC valid, but are we sure some equipment wont play funny games
> with such value ? At least sending "wscale 1-14" must be working...
>   
Well, there at least used to be routers that would actually zeroed the 
WS value in transit while leaving the option set, but this is another 
issue of course.

Anyway, I know Vista at least does set the window scale TCP option by 
default. One assumes they occasionally send a zero value scale. Not that 
Vista is such a good benchmark to compare Linux to but at least I tend 
to believe the issue would have popped up if it is common enough.

I can craft a patch to introduce a route table option to set TCP window 
scale minimum and maximum sizes, similar to window size route option, if 
you there is a need for that. Personally, I think it is just overkill.
>
> My quick&dirty patch was only for discussion, I have no strong opinion on it,
> only that was on one place to patch instead of two/three/four I dont know yet.
>
> So please Gilad & Ori send us a new patch :)
>
>   
Revised patch follows in next email.

Gilad

   

-- 
Gilad Ben-Yossef
Chief Coffee Drinker & CTO
Codefidence Ltd.

Web:   http://codefidence.com
Cell:  +972-52-8260388
Skype: gilad_codefidence
Tel:   +972-8-9316883 ext. 201
Fax:   +972-8-9316884
Email: gilad@codefidence.com

Check out our Open Source technology and training blog - http://tuxology.net

	"Now the world has gone to bed
	 Darkness won't engulf my head
	 I can see by infra-red
	 How I hate the night."

