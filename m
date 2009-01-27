From: Patrick McHardy <kaber@trash.net>
Subject: Re: port bound SAs
Date: Tue, 27 Jan 2009 11:26:57 +0100
Message-ID: <497EE171.1030907@trash.net>
References: <F82446300569AC408EF6BC9E358737947EC12368@exch-one.centrify.com>	<BB7E16A14DE689469A181EC770AFBF4D02A773C1@exch-one.centrify.com> <20090126.222035.100955508.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: paul.moore@centrify.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:33820 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752526AbZA0K1E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2009 05:27:04 -0500
In-Reply-To: <20090126.222035.100955508.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: "Paul Moore" <paul.moore@centrify.com>
> Date: Mon, 26 Jan 2009 11:21:33 -0800
> 
>> A few weeks ago I posted a question to the IETF IPsec group on this
>> topic 
>>
>> I have 2 SPDs declared saying (transport mode)
>> 10.0.0.0/24 port 23 esp
>> 10.0.0.0/24 port 80 esp
>>
>> I then initiate a connection from that Linux machine to another system
>> that has the same logical rules
>> port 23 fires up and I get an SA pair. The question is - does that SA
>> pair belong to port 23 or not
>> If I now connect using port 80 from the same Linux box to the same peer
>> it tries to use the SA already set up for port 23
>> The remote system (windows in my test case) drops the packets because it
>> believes that the SA is for port 23 traffic only
> 
> Why does the Linux system do this?  The route lookup should, as it's
> final IPSEC route lookup action, do an xfrm policy lookup which should
> do a selector match and thus not match the port 23 rule.
> 
> I can't find the code which would allow the sequence of events
> you describe, can you?

I'm guessing that its just the policy that has the port selector set
and the keying daemon does not set it for the installed SAs. So unless
the policies specify seperate SPIs or reqids the SAs will be shared.

Paul, which keying daemon are you using?
