From: Sander Eikelenboom <linux@eikelenboom.it>
Subject: Re: [PATCH net v2] xen-netback: Fix handling of skbs requiring too many slots
Date: Thu, 5 Jun 2014 12:56:31 +0200
Message-ID: <6210063250.20140605125631@eikelenboom.it>
References: <1401908331-13297-1-git-send-email-zoltan.kiss@citrix.com> <20140605100734.GM6043@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Wei Liu <wei.liu2@citrix.com>, xen-devel@lists.xenproject.org,
	<ian.campbell@citrix.com>, <paul.durrant@citrix.com>,
	<netdev@vger.kernel.org>, <david.vrabel@citrix.com>,
	<davem@davemloft.net>
To: Zoltan Kiss <zoltan.kiss@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vserver.eikelenboom.it ([84.200.39.61]:39174 "EHLO
	smtp.eikelenboom.it" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751085AbaFEK4i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2014 06:56:38 -0400
In-Reply-To: <20140605100734.GM6043@zion.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Thursday, June 5, 2014, 12:07:34 PM, you wrote:

> On Wed, Jun 04, 2014 at 07:58:51PM +0100, Zoltan Kiss wrote:
>> A recent commit (a02eb4 "xen-netback: worse-case estimate in xenvif_rx_action is
>> underestimating") capped the slot estimation to MAX_SKB_FRAGS, but that triggers
>> the next BUG_ON a few lines down, as the packet consumes more slots than
>> estimated.
>> This patch introduces full_coalesce on the skb callback buffer, which is used in
>> start_new_rx_buffer() to decide whether netback needs coalescing more
>> aggresively. By doing that, no packet should need more than
>> (XEN_NETIF_MAX_TX_SIZE + 1) / PAGE_SIZE data slots (excluding the optional GSO
>> slot, it doesn't carry data, therefore irrelevant in this case), as the provided
>> buffers are fully utilized.
>> 

Hi Zoltan,

JFYI: tested this patch(v2) and it seems to work fine for my testcases, thanks !

--
Sander
