From: Sebastian Fett <db_extern@gmx.de>
Subject: Re: ARP response with link local IP, why not broadcast
Date: Wed, 22 Jul 2015 09:49:49 +0200
Message-ID: <55AF4B1D.4030208@gmx.de>
References: <55AE5958.3020009@gmx.de>
 <CACP96tRrCzFwTC-fSMxGTWr+zFSkid=Bd6JkGZA822HbEjk4_Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Sowmini Varadhan <sowmini05@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.15]:52007 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753138AbbGVHty (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jul 2015 03:49:54 -0400
In-Reply-To: <CACP96tRrCzFwTC-fSMxGTWr+zFSkid=Bd6JkGZA822HbEjk4_Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> On Tue, Jul 21, 2015 at 4:38 PM, Sebastian Fett <db_extern@gmx.de> wrote:
>> Hello!
>>
>> According to RFC3927 every ARP packet (reply and request) should be sent as
>> link layer broadcast as long as the sender IP is a link local address. (see
>> chapter 2.5).
>
> Because broadcast replies are noisy and should be avoided.
> if possible- it creates a broadcast flood that would wake up all receivers,
> and is especially undesirable in today's world, where bcast would wake
> up sleepy devices, or require other inefficient processes in a cloud env.
> See also https://www.ietf.org/id/draft-nordmark-6man-dad-approaches-01.txt
>
>> That functionality would help me a lot with a use case I have with our
>> application.
>
> what is your use case?
>

My problem ist a local network of audio devices. It is a valid 
possibility that two halfs of the setup are set up individually (Stage 
left and stage right). Both local networks will auto configure 
themselves via link local and will be stable. But there always can be 
two devices with the same IP in both networks.
At one point those two networks will be connected. With the current 
behaviour the conflicting devices will never know of each other and the 
address conflict.
The devices are controlled by a central PC using avahi/bonjour. It will 
know of all conflicting devices, but will only be able to talk to the 
one that happens to be in it's ARP cache. And renewing that cache will 
not change anything, because it will happen with unicast messages.

I looked at a Dante Controller (an audio data streaming device). And 
here all ARP messages are answered with broadcasts.

I think that behaviour is acceptable because it only happens in local 
networks. Waking up sleeping devices will not be a concern there.

That brings me to another question. When I react to an ARP packet in a 
userspace program, can I keep that packet from reaching the kernel as 
well? I would like to avoid to completely handle ARP in userspace.

>>
>> But it is not implemented in the kernel that way.
>> Does anyone know why?

Sebastian
