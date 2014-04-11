From: Jonathan Cooper <jcooper@solarflare.com>
Subject: Re: [RFC PATCH] udp: allow busy_poll on some unconnected sockets
Date: Fri, 11 Apr 2014 11:44:07 +0100
Message-ID: <5347C777.2080901@solarflare.com>
References: <53455581.7060209@solarflare.com>   <20140409145129.GA4002@sbohrermbp13-local.rgmadvisors.com>   <53457334.1030602@solarflare.com>   <alpine.LFD.2.03.1404101856170.27143@solarflare.com>  <1397154745.16584.42.camel@edumazet-glaptop2.roam.corp.google.com>  <5346E520.7080007@solarflare.com> <1397156649.16584.45.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Edward Cree <ecree@solarflare.com>, <netdev@vger.kernel.org>,
	Shawn Bohrer <shawn.bohrer@gmail.com>,
	Shawn Bohrer <sbohrer@rgmadvisors.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:34537 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750892AbaDKKoM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Apr 2014 06:44:12 -0400
In-Reply-To: <1397156649.16584.45.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/04/14 20:04, Eric Dumazet wrote:
> On Thu, 2014-04-10 at 19:38 +0100, Edward Cree wrote:
>> On 10/04/14 19:32, Eric Dumazet wrote:
>>> On Thu, 2014-04-10 at 19:04 +0100, Edward Cree wrote:
>>>
>>>> Tested by setting IFF_SINGLE_NAPI in sfc; a UDP ping-pong test showed a
>>>>   performance benefit from sysctl net.core.busy_{read,poll}=50 in both the
>>>>   connected and unconnected case, where previously it only saw the benefit
>>>>   when the socket had been connected.
>>> Right, but how often do we have single NAPI devices on hosts wanting
>>> very low latencies ?
>>>
>> Well, sfc only has a single NAPI context per device, and I'm fairly sure
>> most sfc users want very low latencies.
>> Or have I misunderstood?
> sfc is multi queue/channel, but has a single NAPI instance ?
>
> Sounds wierd.
>
> Please explain me, how GRO can be efficient.
>
> I believe you have one napi per channel.
>
Whoops, this is my fault, I derped reading our NAPI code. You are 
entirely correct, we do have multiple NAPI instances per device, so our 
proposed scheme is unworkable. We'll just have to connect the socket.
Sorry to waste your time.

Jon
