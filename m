From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC NET 00/02]: Secondary unicast address support
Date: Thu, 21 Jun 2007 14:31:53 -0600
Message-ID: <m1sl8ldp6u.fsf@ebiederm.dsl.xmission.com>
References: <20070620180017.6685.70611.sendpatchset@localhost.localdomain>
	<m13b0lf7mr.fsf@ebiederm.dsl.xmission.com>
	<467ACDE1.7070907@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org,
	davem@davemloft.net, jeff@garzik.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:48289 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755546AbXFUUc4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jun 2007 16:32:56 -0400
In-Reply-To: <467ACDE1.7070907@trash.net> (Patrick McHardy's message of "Thu,
	21 Jun 2007 21:13:37 +0200")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy <kaber@trash.net> writes:

> Eric W. Biederman wrote:
>> I'm trying to understand what the point of this patch is.
>>
>> In once sense I find the concept of filtering and listening for multiple
>> mac addresses very interesting, especially if we could break out different
>> streams of traffic by destination mac address into separate network devices.
>> This would remove the need to any kind of ethernet tunnel and makes multiple
>> network namespaces much more pleasant.
>>
>> However this just seems to allow a card to decode multiple mac addresses
>> which in some oddball load balancing configurations may actually be
>> useful, but it seems fairly limited.
>>
>> Do you have a specific use case you envision for this multiple mac
>> functionality?
>>
>
> Yes, please see the MACVLAN patch I posted one or two days earlier.

Thanks.  That is what I was envisioning.  I keep suspecting one of
the cool multi-rx queue nics my start doing some of the demux in hardware.
But whatever if it works and is relatively fast it is good enough for me.

> 8021q can also make use of it and Dave mentioned some virtualization
> devices want this as well.

Right makes sense.  And ethernet bridging (which is the general case
of the virtualization Dave mentioned should also be able to take
advantage of multiple unicast addresses).  So this definitely make
sense.

Have you done any performance testing with the macvlan code?  With
the ethernet tunnel device we keep getting copied unicast packets on
some path or other which slowed things down.  Simply not doing the
firewalling until the packets have made it through the macvlan device
should help here.

For the macvlan code do we need to do anything special if we transmit
to a mac we would normally receive?  Another unicast mac of the same
nic for example.

For the macvlan hash you just use an upper byte.  Is that just a
simple starting place, or do we not need a more complex hash.

Eric

