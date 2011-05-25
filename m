From: Ben Greear <greearb@candelatech.com>
Subject: Re: VLAN test cases in 2.6.38.7
Date: Tue, 24 May 2011 20:33:28 -0700
Message-ID: <4DDC7888.3010406@candelatech.com>
References: <4DDBFDD6.4060903@candelatech.com>	<4DDC0236.4090800@candelatech.com>	<4DDC36C4.80408@candelatech.com> <20110524.224720.67532722991776785.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:56720 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756090Ab1EYDda (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 May 2011 23:33:30 -0400
In-Reply-To: <20110524.224720.67532722991776785.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/24/2011 07:47 PM, David Miller wrote:
> From: Ben Greear<greearb@candelatech.com>
> Date: Tue, 24 May 2011 15:52:52 -0700
>
>> Either my ubridge code is broken, or 2.6.38.7+ doesn't send
>> tp_vlan_tci
>> properly.  All I ever see is zero for that field.
>
> You need to put the af_packet socket into TPACKET_V2 format.

Actually, that doesn't seem needed.  I just needed to give more
space to the cmsg buffer to account for the cmsg struct overhead.
(And I had a bunch of other bugs, but that was the only one
that directly affected the tci field.)

I think that TPACKET_V2 stuff might be only for reading
memmapped messages or something like that?

It looks like for any flexible user-space code, we are just going
to have to use recvmesg instead of recvfrom, and add the extra checks
for cmesg data.  I'll post code when I get it working better so
the next person to try this might have an easier time :P

I think we will need to add the has-vlan-tci flag to the cmesg
data, and probably also remove that masking of the CFI bit.

I've no idea about socket filters, but maybe someone else can
deal with that :)

Thanks,
Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
