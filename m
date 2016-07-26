From: Hadar Hen Zion <hadarh@dev.mellanox.co.il>
Subject: Re: [PATCH net-next V2 0/2] Mellanox 100G mlx5 minimum inline header mode
Date: Tue, 26 Jul 2016 13:30:46 +0300
Message-ID: <CAJL1qvFjWT4Bk_CdOdU7bECsh327nekVEFENmpU5vwFvNpMxLw@mail.gmail.com>
References: <1469365960-27100-1-git-send-email-saeedm@mellanox.com> <20160725.175436.969233393280158279.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: saeedm@mellanox.com, netdev <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Hadar Hen Zion <hadarh@mellanox.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:36244 "EHLO
	mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750806AbcGZKar (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jul 2016 06:30:47 -0400
Received: by mail-io0-f193.google.com with SMTP id y34so770105ioi.3
        for <netdev@vger.kernel.org>; Tue, 26 Jul 2016 03:30:47 -0700 (PDT)
In-Reply-To: <20160725.175436.969233393280158279.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 26, 2016 at 3:54 AM, David Miller <davem@davemloft.net> wrote:
> From: Saeed Mahameed <saeedm@mellanox.com>
> Date: Sun, 24 Jul 2016 16:12:38 +0300
>
>> This small series from Hadar adds the support for minimum inline
>> header mode query in mlx5e NIC driver.
>>
>> Today on TX the driver copies to the HW descriptor only up to L2
>> header which is the default required mode and sufficient for today's
>> needs.
>>
>> The header in the HW descriptor is used for HW loopback steering
>> decision, without it packets will go directly to the wire with no
>> questions asked.
>>
>> For TX loopback steering according to L2/L3/L4 headers, ConnectX-4
>> requires to copy the corresponding headers into the send queue(SQ)
>> WQE HW descriptor so it can decide whether to loop it back or to
>> forward to wire.
>>
>> For legacy E-Switch mode only L2 headers copy is required.  For
>> advanced steering (E-Switch offloads) more header layers may be
>> required to be copied, the required mode will be advertised by FW to
>> each VF and PF according to the corresponding E-Switch
>> configuration.
>>
>> Changes V2:
>>  - Allocate query_nic_vport_context_out on the stack
>
> Applied, but even doing an eth_get_headlen() every transmitted packet
> it really too expensive.
>
> You shouldn't be touching networking headers so much when forwarding
> frames.

Sorry for re-sending, i had a problem before.

In the default case eth_get_headlen() won't be called, it will happen
only if PF administrator changes the mode from default to L4.

In L4 mode, we need to copy all the packet headers including L4, do
you know of a better/cheaper way for doing that?

Thanks,
Hadar
