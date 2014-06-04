From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: Re: [Xen-devel] [PATCH net] xen-netback: Fix handling of skbs requiring
 too many slots
Date: Wed, 4 Jun 2014 16:42:34 +0100
Message-ID: <538F3E6A.7000002@citrix.com>
References: <1401827406-9341-1-git-send-email-zoltan.kiss@citrix.com> <538F369B.7010100@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <xen-devel@lists.xenproject.org>, <ian.campbell@citrix.com>,
	<wei.liu2@citrix.com>, <paul.durrant@citrix.com>,
	<linux@eikelenboom.it>, <netdev@vger.kernel.org>,
	<david.vrabel@citrix.com>, <davem@davemloft.net>
To: annie li <annie.li@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:43681 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752467AbaFDPmh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jun 2014 11:42:37 -0400
In-Reply-To: <538F369B.7010100@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/06/14 16:09, annie li wrote:
>
> On 2014/6/3 16:30, Zoltan Kiss wrote:
>> A recent commit (a02eb4 "xen-netback: worse-case estimate in
>> xenvif_rx_action is
>> underestimating") capped the slot estimation to MAX_SKB_FRAGS, but
>> that triggers
>> the next BUG_ON a few lines down, as the packet consumes more slots than
>> estimated.
>> This patch introduces full_coalesce on the skb callback buffer, which
>> is used in
>> start_new_rx_buffer() to decide whether netback needs coalescing more
>> aggresively. By doing that, no packet should need more than
>> XEN_NETIF_MAX_TX_SIZE / PAGE_SIZE data slots,
>
> (XEN_NETIF_MAX_TX_SIZE+1) / PAGE_SIZE here?

Do you think about the GSO slot? That's why I wrote "data slot", however 
that's probably not a clear terminology. I'll add then that excluding 
GSO slot, as it doesn't carry data directly, therefore it's irrelevant 
from this point of view.

Zoli
