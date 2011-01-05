From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH v2] net: Allow ethtool to set interface in loopback mode.
Date: Wed, 05 Jan 2011 11:22:21 -0500
Message-ID: <4D249ABD.4080209@garzik.org>
References: <AANLkTikW24AcLEAioYtCwuQOoVnTrqVoAaZw3sksZ_jU@mail.gmail.com> <1294187401-4662-1-git-send-email-maheshb@google.com> <20110104163645.0b3a3687@nehalam> <1294190504.2992.3.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Mahesh Bandewar <maheshb@google.com>,
	David Miller <davem@davemloft.net>,
	Laurent Chavey <chavey@google.com>,
	Tom Herbert <therbert@google.com>,
	netdev <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f181.google.com ([209.85.216.181]:32841 "EHLO
	mail-qy0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751245Ab1AEQW2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Jan 2011 11:22:28 -0500
Received: by qyk12 with SMTP id 12so17533153qyk.19
        for <netdev@vger.kernel.org>; Wed, 05 Jan 2011 08:22:27 -0800 (PST)
In-Reply-To: <1294190504.2992.3.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/04/2011 08:21 PM, Ben Hutchings wrote:
> On Tue, 2011-01-04 at 16:36 -0800, Stephen Hemminger wrote:
>> On Tue,  4 Jan 2011 16:30:01 -0800
>> Mahesh Bandewar<maheshb@google.com>  wrote:
>>
>>> This patch enables ethtool to set the loopback mode on a given interface.
>>> By configuring the interface in loopback mode in conjunction with a policy
>>> route / rule, a userland application can stress the egress / ingress path
>>> exposing the flows of the change in progress and potentially help developer(s)
>>> understand the impact of those changes without even sending a packet out
>>> on the network.
>>>
>>> Following set of commands illustrates one such example -
>>> 	a) ip -4 addr add 192.168.1.1/24 dev eth1
>>> 	b) ip -4 rule add from all iif eth1 lookup 250
>>> 	c) ip -4 route add local 0/0 dev lo proto kernel scope host table 250
>>> 	d) arp -Ds 192.168.1.100 eth1
>>> 	e) arp -Ds 192.168.1.200 eth1
>>> 	f) sysctl -w net.ipv4.ip_nonlocal_bind=1
>>> 	g) sysctl -w net.ipv4.conf.all.accept_local=1
>>> 	# Assuming that the machine has 8 cores
>>> 	h) taskset 000f netserver -L 192.168.1.200
>>> 	i) taskset 00f0 netperf -t TCP_CRR -L 192.168.1.100 -H 192.168.1.200 -l 30
>>>
>>> Signed-off-by: Mahesh Bandewar<maheshb@google.com>
>>> Reviewed-by: Ben Hutchings<bhutchings@solarflare.com>
>>
>> Since this is a boolean it SHOULD go into ethtool_flags rather than
>> being a high level operation.
>
> It could do, but I though ETHTOOL_{G,S}FLAGS were intended for
> controlling offload features.

It doesn't have to be.  As Stephen guessed, [GS]FLAGS are basically 
common flags -- as differentiated from private, 
driver-specific/hardware-specific flags.

	Jeff



