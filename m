From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 1/3] vlan: Do not support clearing VLAN_FLAG_REORDER_HDR
Date: Tue, 24 May 2011 00:56:08 -0700
Message-ID: <m1zkmco7l3.fsf@fess.ebiederm.org>
References: <20110523140048.777fb378@nehalam>
	<20110523.172047.1438754754048434316.davem@davemloft.net>
	<m1y61x2htp.fsf@fess.ebiederm.org>
	<20110524.011942.393855175233217324.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@linux-foundation.org, greearb@candelatech.com,
	nicolas.2p.debian@gmail.com, jpirko@redhat.com, xiaosuo@gmail.com,
	netdev@vger.kernel.org, kaber@trash.net, fubar@us.ibm.com,
	eric.dumazet@gmail.com, andy@greyhouse.net, jesse@nicira.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:43740 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754032Ab1EXH4R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 May 2011 03:56:17 -0400
In-Reply-To: <20110524.011942.393855175233217324.davem@davemloft.net> (David
	Miller's message of "Tue, 24 May 2011 01:19:42 -0400 (EDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

> From: ebiederm@xmission.com (Eric W. Biederman)
> Date: Mon, 23 May 2011 15:05:54 -0700
>
>> 3) What do we do with pf_packet and vlan hardware acceleration when
>>    dumping not the vlan interface but the interface below the vlan
>>    interface?
>> 
>>    Do we provide an option to keep the vlan header?  Should that option
>>    be on by default?
>> 
>
> The vlan_tci in the V2 pf_packet auxdata was intended for this
> purpose.
>
> So no matter what variant of behavior is occurring, apps can properly
> reconstitute the VLAN header if they inspect the vlan_tci in the
> auxdata.

It sucks a little bit to deal with that but that is fair.

> The only thing that seems to be missing is an indication that a VLAN
> tag was present at all, ie. vlan_tx_tag_present(), in this manner an
> application could then differentiate between no VLAN header and a VLAN
> tag of zero.

Good point.

I had seen that we were putting the data there but I missed the fact
that we deleted the indicator.  That makes packets not destined for a
vlan but that just have priority bits set hard to detect.  Especially
if the priority bits are 0.

Would it cause many problems if we added used tp_status to hold a flag
indicating the presence of a vlan header?

We also have an issue that the socket filter doesn't have access to any
of the vlan information at present.

Eric

