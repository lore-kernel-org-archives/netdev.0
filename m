From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH] softmac: Fix WX and association related races
Date: Thu, 28 Sep 2006 10:16:31 -0500
Message-ID: <451BE74F.3010908@lwfinger.net>
References: <200609271726.34305.mb@bu3sch.de> <1159453641.2648.20.camel@ux156> <1159454237.2642.17.camel@localhost.localdomain> <200609281643.04631.mb@bu3sch.de> <1159455169.2642.30.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Michael Buesch <mb@bu3sch.de>, linville@tuxdriver.com,
	netdev@vger.kernel.org, Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc13.worldnet.att.net ([204.127.131.117]:30858 "EHLO
	mtiwmhc13.worldnet.att.net") by vger.kernel.org with ESMTP
	id S964993AbWI1PQh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Sep 2006 11:16:37 -0400
To: Dan Williams <dcbw@redhat.com>
In-Reply-To: <1159455169.2642.30.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dan Williams wrote:
> On Thu, 2006-09-28 at 16:43 +0200, Michael Buesch wrote:
>> On Thursday 28 September 2006 16:37, Dan Williams wrote:
>>> On Thu, 2006-09-28 at 16:27 +0200, Johannes Berg wrote:
>>>> On Thu, 2006-09-28 at 10:19 -0400, Dan Williams wrote:
>>>>
>>>>> I'd buy that argument.  When the driver gets the deauth message,
>>>>> shouldn't it be sending an IWAP 00:00:00:00:00:00 wireless event to
>>>>> userspace?
>>>> I thought we did that since a long time now, didn't you actually develop
>>>> the initial patch?
>>> Yes, I think I did.  My point here wasn't that the driver is _not_
>>> sending those messages (it almost certainly is), but what's _implied_ by
>>> those messages.  Namely that, if you're using a tool like wpa_supplicant
>>> and/or NM, when you get a deauth from the AP and send the IWAP event,
>>> all bets are off because the tool will likely override whatever the
>>> driver thinks its doing.
>>>
>>> I'm somewhat ambiguous on just how much policy a driver should try to
>>> enforce.  I guess I'm OK with reassociation with the _same_ credentials.
>>> But what airo does with "auto_wep" is very nearly, if not completely,
>>> crossing the line [1].  The real question is, how much should drivers
>>> really do, and how much should they leave to userspace?
>> IMO a driver should implement absolutely _zero_ policy, as this
>> is the only way to get the same (default) policy for different
>> cards. A driver should _only_ provide generic events for
>> userspace tools to make decisions.
>> A "I got a deauth" event is really enough for userspace to
>> know what to do.
> 
> As a counterpoint, does every developer _really_ want to run
> wpa_supplicant just to use a WEP-encrypted connection where you may
> occasionally get kicked off?
> 
> I think it's clear that with WPA, it's pretty nearly impossible to do
> reauth/reassoc because you need a user-space supplicant, right?  But WEP
> doesn't require any interaction other than the 2- or 4-stage handshake
> for open or shared key, and that's already done in the driver.
> 
> I'd say that handling WEP reauth/reassoc in the driver is probably fine
> [1] since many drivers already try to do this, but I believe it's
> probably inappropriate for anything more than WEP.  It's probably also
> impossible to do with any sort of more-than-WEP roaming, maybe even WEP
> roaming.
> 
> Dan
> 
> [1] with a suitable timeout or #tries clamp so it doesn't try forever.
> airo does the auto_wep thing twice before failing and sending IWAP
> 00:00:... I believe.
> 
>>> Dan
>>>
>>> [1] if the auth mode (open or shared-key) doesn't work, airo schedules a
>>> timer and bumps the auth mode to the other one automatically, and tries
>>> reassociation.

Thanks for the educational discourse here. I have quite a bit of food for thought.

First of all, my problem is quite likely caused by a buggy AP. It is a Linksys WRT54G V5, which is 
one of those with a VxWorks kernel, not Linux. I have already reported one bug to Linksys, which 
they have neither acknowledged nor fixed! In that case, SoftMAC had to be modified as a work-around.

I don't know why the deauthentication is being sent. The reason is not logged, which will be my 
first change in the code. The second place to look is why SoftMAC reports the network is unknown 
when the MAC printed is that of my AP.

Once I know more about the above points, I'll likely be back with more questions. Once I get the 
response to the deauthentication to be better behaved, I will retry Michael's patch. The main 
difficulty in all of this is that it happens even less frequently than the NETDEV WATCHDOG timeouts, 
which were bad enough to troubleshoot.

Thanks again,

Larry

