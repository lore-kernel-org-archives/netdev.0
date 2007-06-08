From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH] Virtual ethernet tunnel (v.2)
Date: Fri, 08 Jun 2007 16:46:32 -0700
Message-ID: <4669EA58.3000306@candelatech.com>
References: <4667E83E.2060405@openvz.org> <466822DD.1000601@candelatech.com>	<466826C6.6000206@openvz.org>	<46682976.8050904@candelatech.com> <46697D0A.40006@openvz.org> <46698B24.2030309@candelatech.com> <4669B2BD.5060208@gmx.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Pavel Emelianov <xemul@openvz.org>,
	Kirill Korotaev <dev@openvz.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Linux Containers <containers@lists.osdl.org>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Patrick McHardy <kaber@trash.net>
To: Carl-Daniel Hailfinger <c-d.hailfinger.devel.2006@gmx.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:50049 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762870AbXFHXqq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Jun 2007 19:46:46 -0400
In-Reply-To: <4669B2BD.5060208@gmx.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Carl-Daniel Hailfinger wrote:
> On 08.06.2007 19:00, Ben Greear wrote:
>> I have another sysfs patch that allows setting a default skb->mark for
>> an interface so that you can set the skb->mark
>> before it hits the connection tracking logic, but I'm been told this one
>> has very little chance
>> of getting into the kernel.  The skb->mark patch is only useful (as far
>> as I can tell) if you
>> also include a patch Patrick McHardy did for me that allowed the
>> conn-tracking logic to
>> use skb->mark as part of it's tuple.  This allows me to do NAT between
>> virtual routers
>> (routing tables) on the same machine using veth-equivalent drivers to
>> connect the
>> routers.  He thinks this will probably not ever get into the kernel either.
> 
> Are these patches available somewhere? I'm currently doing NAT between
> virtual routers by some advanced iproute2/iptables trickery, but I have
> no way to handle the occasional tuple conflict.

A consolidated patch against 2.6.20.12 is here.  It has a lot more than
just the patches mentioned above, but it shouldn't hurt anything to have
the whole patch applied:

http://www.candelatech.com/oss/candela_2.6.20.patch

The original patch for using skb->mark as a tuple was
written by Patrick McHardy, and is here:

http://www.candelatech.com/oss/skb_mark_conntrack.patch

His patch merged with my patch to sysfs to set skb->mark on ingress is here:
http://www.candelatech.com/oss/conntrack_mark_with_ssyctl.patch


Thanks,
Ben


> 
> Regards,
> Carl-Daniel


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

