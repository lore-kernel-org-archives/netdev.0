From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: Re: [PATCH net] xen-netback: Fix handling of skbs requiring too many
 slots
Date: Wed, 4 Jun 2014 16:53:18 +0100
Message-ID: <538F40EE.2040609@citrix.com>
References: <1401827406-9341-1-git-send-email-zoltan.kiss@citrix.com> <063D6719AE5E284EB5DD2968C1650D6D17256EE9@AcuExch.aculab.com> <538EF1B3.40904@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"david.vrabel@citrix.com" <david.vrabel@citrix.com>,
	"davem@davemloft.net" <davem@davemloft.net>
To: David Laight <David.Laight@ACULAB.COM>,
	"xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>,
	"ian.campbell@citrix.com" <ian.campbell@citrix.com>,
	"wei.liu2@citrix.com" <wei.liu2@citrix.com>,
	"paul.durrant@citrix.com" <paul.durrant@citrix.com>,
	"linux@eikelenboom.it" <linux@eikelenboom.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:56048 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751592AbaFDPxW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jun 2014 11:53:22 -0400
In-Reply-To: <538EF1B3.40904@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/06/14 11:15, Zoltan Kiss wrote:
> On 04/06/14 09:50, David Laight wrote:
>> From: netdev-owner@vger.kernel.org
>>> A recent commit (a02eb4 "xen-netback: worse-case estimate in
>>> xenvif_rx_action is
>>> underestimating") capped the slot estimation to MAX_SKB_FRAGS, but
>>> that triggers
>>> the next BUG_ON a few lines down, as the packet consumes more slots than
>>> estimated.
>>> This patch introduces full_coalesce on the skb callback buffer, which
>>> is used in
>>> start_new_rx_buffer() to decide whether netback needs coalescing more
>>> aggresively. By doing that, no packet should need more than
>>> XEN_NETIF_MAX_TX_SIZE / PAGE_SIZE data slots, as the provided buffers
>>> are fully
>>> utilized.
>> ...
>>> -static bool start_new_rx_buffer(int offset, unsigned long size, int
>>> head)
>>> +static bool start_new_rx_buffer(int offset,
>>> +                unsigned long size,
>>> +                int head,
>>> +                bool full_coalesce)
>>
>> The above is completely incorrect layout ...
> Can you elaborate a bit please on "above"?

I just realized you're not talking about skb layout but format. I'll fix 
that.

Zoli
