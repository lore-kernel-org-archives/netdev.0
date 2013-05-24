From: Holger Brunck <holger.brunck@keymile.com>
Subject: Re: napi layer and packet throttling
Date: Fri, 24 May 2013 11:39:03 +0200
Message-ID: <519F3537.8050603@keymile.com>
References: <519E030E.5040903@keymile.com> <1369348056.6963.25.camel@bwh-desktop.uk.level5networks.com> <519F1698.3050301@keymile.com> <CAHdPZaPChc_EUW_Y+Dvu16nsAGZpe00BRm08-2NW=p+8hDt1yA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>, netdev@vger.kernel.org
To: "devendra.aaru" <devendra.aaru@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-de.keymile.com ([195.8.104.250]:58816 "EHLO
	mail-de.keymile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760070Ab3EXJjI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 May 2013 05:39:08 -0400
In-Reply-To: <CAHdPZaPChc_EUW_Y+Dvu16nsAGZpe00BRm08-2NW=p+8hDt1yA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/24/2013 11:20 AM, devendra.aaru wrote:
> On Fri, May 24, 2013 at 12:58 PM, Holger Brunck
>>
>> On 05/24/2013 12:27 AM, Ben Hutchings wrote:
>>> On Thu, 2013-05-23 at 13:52 +0200, Holger Brunck wrote:
>>>> b) Packet-Throttling
>>>> Here the description says "NAPI-compliant drivers can often cause packets to be
>>>> dropped in the network adaptor itself, before the kernel sees them at all."
>>>>
>>>> This is exactly what I need for my usecase. But I don't see any hints how this
>>>> can be implemented with the napi layer.
>>> [...]
>>>
>>> If the RX ring is not cleaned and refilled quickly enough, the network
>>> controller will naturally start to drop packets.  It's not something you
>>> should do explicitly in the driver.
>>>
>>
>> yes. But what if the remaining amount of packets which are getting through the
>> napi_poll function into the linux system are still to many and generate
>> therefore a to high softirq load on the system which leads to the problems I
>> see. Ok I could use a smaller amount of RX ring buffers, but then the system
>> would get more intolerant for RX bursts what I don't want. I would like to
>> protect the system if someone sends continuously a high packet rate to the
>> interface, similar to DoS attacks.
> 
> 
> what if i measure no. of packets over a period of time and find the
> rate of arrival (packets/msec) and if that rate is greater than the
> choosen rate, allow only packets that are in the window that you can
> accept, This window can be time window or the number of packets (like
> 1 packet in 10 usec or 1 packet out of 100 packets). Like wise this
> measurement can be repeated after every full period.
> 

thats similar to what I have implemented in ucc_geth.c for my workspace and yes
whith such a mechanism my problems seems to be fixed. But I still ask myself if
there is a common approach for such a problem already implemented in similar
drivers...

Regards
Holger
