From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: Re: [PATCH 3/3][net-next] gianfar: Pack struct gfar_priv_grp into
 three cachelines
Date: Tue, 29 Jan 2013 17:19:47 +0200
Message-ID: <5107E893.9030706@freescale.com>
References: <1359467712-32079-1-git-send-email-claudiu.manoil@freescale.com> <1359467712-32079-2-git-send-email-claudiu.manoil@freescale.com> <1359467712-32079-3-git-send-email-claudiu.manoil@freescale.com> <AE90C24D6B3A694183C094C60CF0A2F6026B7124@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from db3ehsobe002.messaging.microsoft.com ([213.199.154.140]:55330
	"EHLO db3outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753858Ab3A2PUK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2013 10:20:10 -0500
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B7124@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/29/2013 4:35 PM, David Laight wrote:
>> * remove unused members(!): imask, ievent
>> * move space consuming interrupt name strings (int_name_* members) to
>> external structures, unessential for the driver's hot path
>> * keep high priority hot path data within the first 2 cache lines
>>
>> This reduces struct gfar_priv_grp from 6 to 3 cache lines.
>
> Does it really matter where the message texts are allocated?
> Provided they aren't intermixed with the 'hot' data.
> Allocating them separately just seems over complicated.
>
> 	David
>

Hello David,

I think that the size of 'struct gfar_priv_grp' matters because we have
struct gfar_private {
	...
	struct gfar_priv_grp gfargrp[2];
	...
}
which in turn will be bloated by an unnecessarily large gfar_priv_grp.
gfar_private also contains a fair number of runtime critical members
(including gfargrp) and we want those members to fit into as few
cachelines as possible too. Also, it would be wasteful to have memory
holes inside struct gfar_priv_grp, in this context, and the current
patch resolves those memory holes, by compacting this structure to
exactly 96 bytes.

I don't find this change over complicated, but I'm open to suggestions
on where to move those message texts, outside of gfar_priv_grp (or
other runtime critical structure).

Thanks,
Claudiu
