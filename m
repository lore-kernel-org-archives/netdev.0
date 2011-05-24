From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH 1/3] vlan: Do not support clearing VLAN_FLAG_REORDER_HDR
Date: Tue, 24 May 2011 08:44:36 -0700
Message-ID: <4DDBD264.5030709@candelatech.com>
References: <20110523140048.777fb378@nehalam>	<20110523.172047.1438754754048434316.davem@davemloft.net>	<m1y61x2htp.fsf@fess.ebiederm.org> <20110524.011942.393855175233217324.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, shemminger@linux-foundation.org,
	nicolas.2p.debian@gmail.com, jpirko@redhat.com, xiaosuo@gmail.com,
	netdev@vger.kernel.org, kaber@trash.net, fubar@us.ibm.com,
	eric.dumazet@gmail.com, andy@greyhouse.net, jesse@nicira.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:52013 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755747Ab1EXPpG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 May 2011 11:45:06 -0400
In-Reply-To: <20110524.011942.393855175233217324.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/23/2011 10:19 PM, David Miller wrote:
> From: ebiederm@xmission.com (Eric W. Biederman)
> Date: Mon, 23 May 2011 15:05:54 -0700
>
>> 3) What do we do with pf_packet and vlan hardware acceleration when
>>     dumping not the vlan interface but the interface below the vlan
>>     interface?
>>
>>     Do we provide an option to keep the vlan header?  Should that option
>>     be on by default?
>>
>
> The vlan_tci in the V2 pf_packet auxdata was intended for this
> purpose.
>
> So no matter what variant of behavior is occurring, apps can properly
> reconstitute the VLAN header if they inspect the vlan_tci in the
> auxdata.

When using pf-packet on eth0, with no VLAN devices existing, would
you still be putting the VLAN tags in auxdata, or would the tags be
inline in the skb?

> The only thing that seems to be missing is an indication that a VLAN
> tag was present at all, ie. vlan_tx_tag_present(), in this manner an
> application could then differentiate between no VLAN header and a VLAN
> tag of zero.

For nested VLANs, the outside VLAN data is in the auxdata, and the rest
is inline in the packet?

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
