From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: IPv6 route to gateway on fe80::1%eth0 when I have fe80::1%br0
 locally
Date: Tue, 23 Feb 2016 10:03:28 +0100
Message-ID: <56CC2060.1050904@stressinduktion.org>
References: <20151212195830.GA18286@torres.zugschlus.de>
 <56796902.8080703@stressinduktion.org>
 <20151222212843.GE4424@torres.zugschlus.de>
 <5679C58C.2090308@stressinduktion.org>
 <20160222150443.GV26042@torres.zugschlus.de>
 <56CB2564.9030003@stressinduktion.org>
 <20160222154758.GW26042@torres.zugschlus.de>
 <56CB342D.9010100@stressinduktion.org>
 <20160222192039.GC26042@torres.zugschlus.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Marc Haber <mh+netdev@zugschlus.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:33055 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751644AbcBWJDb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Feb 2016 04:03:31 -0500
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
	by mailout.nyi.internal (Postfix) with ESMTP id 306DD20968
	for <netdev@vger.kernel.org>; Tue, 23 Feb 2016 04:03:31 -0500 (EST)
In-Reply-To: <20160222192039.GC26042@torres.zugschlus.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 22.02.2016 20:20, Marc Haber wrote:
> On Mon, Feb 22, 2016 at 05:15:41PM +0100, Hannes Frederic Sowa wrote:
>> On 22.02.2016 16:47, Marc Haber wrote:
>>> Can you reproduce the behavior with accept_ra_from_local =0 as well?
>>> Unfortunately, the debugging VM I build works fine, it's just the
>>> physical host showing this behavior. This is really strange.
>>
>> Same here. Debugging VM didn't show this error at all and other systems
>> didn't show this symptom either (4.4.2 as well as net-next).
>>
>> With which kernel did you see this behavior for the first time and what was
>> the last working version?
>
> Thanks for motivating me to investigate this further.
>
> I have to apologize. It is not a kernel issue.
>
> It has turned out that systemd, starting with version 229, has placed
> a "Not invented here" stamp on route advertisement processing in the
> kernel and has implemented its own userspace code to handle router
> advertisements.
>
> And, of course, they did it wrong.
>
> Setting IPv6AcceptRouterAdvertisements=0 in eth0.network seems to
> disable enough code that this issue does not show any more.
>
> Sorry for the rumble, I debugged the wrong piece of software. Bugs in
> Debian are filed, #815582, #815586. I don't file bugs with systemd
> upstream any more since I got silenced on systemd-devel for losing my
> temper.

Thanks for letting me know. Hopefully this also fixes 
https://bugzilla.kernel.org/show_bug.cgi?id=110721.

Thanks,
Hannes
