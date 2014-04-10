From: Edward Cree <ecree@solarflare.com>
Subject: Re: [RFC PATCH] udp: allow busy_poll on some unconnected sockets
Date: Thu, 10 Apr 2014 19:38:24 +0100
Message-ID: <5346E520.7080007@solarflare.com>
References: <53455581.7060209@solarflare.com>  <20140409145129.GA4002@sbohrermbp13-local.rgmadvisors.com>  <53457334.1030602@solarflare.com>  <alpine.LFD.2.03.1404101856170.27143@solarflare.com> <1397154745.16584.42.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, Shawn Bohrer <shawn.bohrer@gmail.com>,
	"Shawn Bohrer" <sbohrer@rgmadvisors.com>,
	Jonathan Cooper <jcooper@solarflare.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:16852 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965159AbaDJSi2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Apr 2014 14:38:28 -0400
In-Reply-To: <1397154745.16584.42.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/04/14 19:32, Eric Dumazet wrote:
> On Thu, 2014-04-10 at 19:04 +0100, Edward Cree wrote:
>
>> Tested by setting IFF_SINGLE_NAPI in sfc; a UDP ping-pong test showed a
>>  performance benefit from sysctl net.core.busy_{read,poll}=50 in both the
>>  connected and unconnected case, where previously it only saw the benefit
>>  when the socket had been connected.
> Right, but how often do we have single NAPI devices on hosts wanting
> very low latencies ?
>
Well, sfc only has a single NAPI context per device, and I'm fairly sure
most sfc users want very low latencies.
Or have I misunderstood?

(Note that it doesn't matter if there are other NAPI-using devices on
the host, since the socket is bound to a local address and thus is only
going to receive packets from the one device that has that address.  So
maybe IFF_SINGLE_NAPI is a bad name and it should be
IFF_DEVICE_ONLY_HAS_A_SINGLE_NAPI_CONTEXT.  But that's a bit unwieldy ;)
