From: Michal Kazior <michal.kazior@tieto.com>
Subject: Re: [PATCH] ipv6: allow bypassing cross-intf routing limits
Date: Mon, 18 Apr 2016 11:38:42 +0200
Message-ID: <CA+BoTQ=8fbfQ9WuY=2+O-_uCu4qFJj33a3fTD_K4OC2HLD=J_A@mail.gmail.com>
References: <1459757755-25424-1-git-send-email-michal.kazior@tieto.com>
	<1460637988-31606-1-git-send-email-michal.kazior@tieto.com>
	<20160416.184936.1899675200733835878.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Network Development <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:36780 "EHLO
	mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751972AbcDRJio convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Apr 2016 05:38:44 -0400
Received: by mail-wm0-f53.google.com with SMTP id v188so110618651wme.1
        for <netdev@vger.kernel.org>; Mon, 18 Apr 2016 02:38:43 -0700 (PDT)
In-Reply-To: <20160416.184936.1899675200733835878.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17 April 2016 at 00:49, David Miller <davem@davemloft.net> wrote:
> From: Michal Kazior <michal.kazior@tieto.com>
> Date: Thu, 14 Apr 2016 14:46:28 +0200
>
>> There are some use-cases to allow link-local
>> routing for bridging purposes.
>>
>> One of these is allowing transparent 802.11
>> bridging. Due to 802.11 framing limitations many
>> Access Points make it impossible to create bridges
>> on Client endpoints because they can't maintain
>> Destination/Source/Transmitter/Receiver address
>> distinction with only 3 addresses in frame header.
>>
>> The default behavior, i.e. link-local traffic
>> being non-routable, remains. The user has to
>> explicitly enable the bypass when defining a given
>> route.
>>
>> Signed-off-by: Michal Kazior <michal.kazior@tieto.com>
>
> Sorry, whilst I realize your problem, I'm not going to add what is
> explicitly a violation of the way link-local addresses are meant to
> work and the very much intentional restrictions the RFCs place upon
> them (they MUST not be routed).
>
> I also didn't see any real discussions in response to your original
> proposals, not from even one person I know is knowledgable about ipv6
> and the implications your change would have, and that is extremely
> troubling.
>
> I tried to let your patches sit for several days in order to let that
> kind of discussion happen, but it didn't.

I totally understand. Thanks anyway.


> So, you'll need to find another way to achieve your goals.

Hmm.. I actually do have another idea in mind already.

I was wondering about about implementing a link device in a similar
fashion to macvlan, bridge, et al, i.e. the device would take an
interface (wlan interface in my case) as a slave and perform L2
address mangling (which should be enough to accommodate the addressing
deficiency in wireless client modes). The device would obviously need
to do some L3/L4 packet inspection and manipulation.

Would something like that be acceptable? Thoughts?


Micha=C5=82
