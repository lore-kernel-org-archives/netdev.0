From: Ben Greear <greearb@candelatech.com>
Subject: Re: MACVLANs really best solution? How about a bridge with multiple
 bridge virtual interfaces?
Date: Mon, 09 Mar 2009 14:23:40 -0700
Message-ID: <49B588DC.40309@candelatech.com>
References: <20090307211527.6e76d0b9.nanog@85d5b20a518b8f6864949bd940457dc124746ddc.nosense.org>	<49B51A42.6050507@trash.net> <m11vt6d9t6.fsf@fess.ebiederm.org>	<49B52F73.7010508@trash.net> <m13admbsuk.fsf@fess.ebiederm.org>	<49B53B6C.7060400@trash.net> <m1fxhm8xl1.fsf@fess.ebiederm.org>	<49B5478C.4020001@trash.net> <49B566DF.3040603@candelatech.com> <m17i2y5rbw.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	Mark Smith
	<nanog@85d5b20a518b8f6864949bd940457dc124746ddc.nosense.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	shemminger@linux-foundation.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:35441 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753669AbZCIVXx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2009 17:23:53 -0400
In-Reply-To: <m17i2y5rbw.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric W. Biederman wrote:
> Ben Greear <greearb@candelatech.com> writes:
> 
>> Patrick McHardy wrote:
>>
>>>> Now that I think about it we could call ndo_start_xmit directly
>>>> from the macvlan code, and bypass whatever hook we use to
>>>> intercept packets going out the normal device it should not
>>>> be too difficult.
>>> We don't intercept packets on TX, they have to be explicitly delivered
>>> to macvlan.
>> It might suck for performance, but mac-vlan could register an 'ALL' protocol
>> on the physical dev, similar to tcp-dump, to grab pkts on tx and pass the
>> ones it cares about back up to the vlans?
> 
> I like that idea.  At least for prototyping.
> 
> I wonder if pkt_type all could be have a per interface optimized variant.
> 
>> I'd want run-time control to disable any of these costly options for those that
>> don't need it, however.
> 
> If well implemented it should not be more expensive than the ingress path where
> we already have, and where we already do that.  Unless your traffic is highly
> assymmetric.

Well, the ingress path isn't free, and especially for broadcast pkts it is quite
expensive with large numbers of devices.

In a single namespace implementation, there are very few uses for having two
NICs on the same system able to send to each other since an un-patched kernel
will not do IPv4 traffic between two external ports, and multicast loops back
in software already.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

