From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: RE: Question regarding MAC address configuraton with VLAN devices
Date: Wed, 8 Apr 2015 05:49:59 +0000
Message-ID: <B5657A6538887040AD3A81F1008BEC63C26107@avmb3.qlogic.org>
References: <31AFFC7280259C4184970ABA9AFE8B93E0930C40@avmb3.qlogic.org>
 <5523FB49.9010107@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>
To: Alexander Duyck <alexander.h.duyck@redhat.com>,
	Manish Chopra <manish.chopra@qlogic.com>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:55088 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751140AbbDHFuJ convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Apr 2015 01:50:09 -0400
In-Reply-To: <5523FB49.9010107@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> What you are proposing would likely require significant changes to more than
> just VLANs.  It would have an impact on all stacked devices since normally the
> assumption is that we push addresses down, not up.  That is why the
> vlan_sync_address is simply checking to see if its current address is supported
> before pushing the address down.
> 
> Maybe we should look into adding some sort of flag to indicate that the address
> table is locked, like a IFF_L2_ADDR_LOCKED in order to indicate that the device
> only supports one L2 address and cannot be changed.
> Then you could probably pass that up to higher levels to force things like the
> address change you want in VLAN, and things like MACVLAN would simply fail if
> that flag is set.
> 
> - Alex

I think there's an even simpler question here -
Today, if you'll have a network interface with a vlan stacked on top of it
and user calls 'ip link set ... address ...' the end result would be that the vlan
interface retains the original MAC and push it downward [to base device].
You can claim this is harmless, but I don't really think anyone intends this to
happen. [You may claim this is not an interesting flow, and you'll probably
be right; but that's beside the point ;-) ]

Perhaps limiting this only for devices-that-support-a-single-l2-address is too
harsh; Although in that case, we'll need to distinguish between MAC address
that were passed upward [e.g., vlan interface] and downward [e.g., macvlan], 
