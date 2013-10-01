From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Established sockets remain open after iface down or address lost
Date: Tue, 01 Oct 2013 10:06:17 -0700
Message-ID: <524B0109.80007@hp.com>
References: <20130926060433.GA9170@cverges-dev-lnx.sentient-energy.com> <1380203383.3165.172.camel@edumazet-glaptop> <20131001132707.GA7442@cverges-dev-lnx.sentient-energy.com> <524AEDD1.9010709@hp.com> <20131001160825.GA8784@cverges-dev-lnx.sentient-energy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, davem@davemloft.net,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org
To: Chris Verges <cverges@sentient-energy.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0029.austin.hp.com ([15.216.28.36]:44939 "EHLO
	g1t0029.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751121Ab3JARGW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Oct 2013 13:06:22 -0400
In-Reply-To: <20131001160825.GA8784@cverges-dev-lnx.sentient-energy.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/01/2013 09:08 AM, Chris Verges wrote:
> On Tue, Oct 01, 2013 at 08:44:17AM -0700, Rick Jones wrote:
>> The protocol between client and server needs to have an
>> application-layer "keepalive" mechanism added, and then the server
>> will be able to detect a dangling connection without need of any
>> further kernel modifications.
>>
>> If that is not possible, the server can/should set SO_KEEPALIVE and
>> perhaps tweak the TCP keepalive settings.  Not as good (IMO) as an
>> application-layer keepalive because it only shows that the connection
>> is good as far as TCP, but I suppose it could do in a pinch.
>
> I agree that some form of keepalives would solve the problem where
> blocking reads need to be interrupted.  However, this creates traffic
> across the link -- directly proportional to the keepalive interval.
>
> The underlying physical layer is such that we pay for all traffic going
> across it -- including any keepalives at either the application or TCP
> layers.  Paying for this keepalive traffic when the link is operational
> is not desired.

Pick your poison :)

If the server application is in a "I know there should be (more) data 
arriving on this connection" mode, then you can simply have an 
application-layer timeout in the server code that does not rely on 
active probing the connection.

Otherwise, even if you do get some sort of "nuke connections using a 
source IP matching an interface we just brought down" option into the 
kernel, you will still have the small matter of something else between 
the client and server going down that neither can see directly.

rick jones
