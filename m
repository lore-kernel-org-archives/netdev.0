From: "devendra.aaru" <devendra.aaru@gmail.com>
Subject: Re: napi layer and packet throttling
Date: Fri, 24 May 2013 14:50:42 +0530
Message-ID: <CAHdPZaPChc_EUW_Y+Dvu16nsAGZpe00BRm08-2NW=p+8hDt1yA@mail.gmail.com>
References: <519E030E.5040903@keymile.com>
	<1369348056.6963.25.camel@bwh-desktop.uk.level5networks.com>
	<519F1698.3050301@keymile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Ben Hutchings <bhutchings@solarflare.com>, netdev@vger.kernel.org
To: Holger Brunck <holger.brunck@keymile.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:57740 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752649Ab3EXJUn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 May 2013 05:20:43 -0400
Received: by mail-wi0-f180.google.com with SMTP id hn14so2584839wib.13
        for <netdev@vger.kernel.org>; Fri, 24 May 2013 02:20:42 -0700 (PDT)
In-Reply-To: <519F1698.3050301@keymile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 24, 2013 at 12:58 PM, Holger Brunck
<holger.brunck@keymile.com> wrote:
> Hi Ben,
>
> On 05/24/2013 12:27 AM, Ben Hutchings wrote:
>> On Thu, 2013-05-23 at 13:52 +0200, Holger Brunck wrote:
>>> b) Packet-Throttling
>>> Here the description says "NAPI-compliant drivers can often cause packets to be
>>> dropped in the network adaptor itself, before the kernel sees them at all."
>>>
>>> This is exactly what I need for my usecase. But I don't see any hints how this
>>> can be implemented with the napi layer.
>> [...]
>>
>> If the RX ring is not cleaned and refilled quickly enough, the network
>> controller will naturally start to drop packets.  It's not something you
>> should do explicitly in the driver.
>>
>
> yes. But what if the remaining amount of packets which are getting through the
> napi_poll function into the linux system are still to many and generate
> therefore a to high softirq load on the system which leads to the problems I
> see. Ok I could use a smaller amount of RX ring buffers, but then the system
> would get more intolerant for RX bursts what I don't want. I would like to
> protect the system if someone sends continuously a high packet rate to the
> interface, similar to DoS attacks.


what if i measure no. of packets over a period of time and find the
rate of arrival (packets/msec) and if that rate is greater than the
choosen rate, allow only packets that are in the window that you can
accept, This window can be time window or the number of packets (like
1 packet in 10 usec or 1 packet out of 100 packets). Like wise this
measurement can be repeated after every full period.


>
> Regards
> Holger
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
