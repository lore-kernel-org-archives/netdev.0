From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [PATCHv2] netfilter: Remove skb_is_nonlinear check from
 nf_conntrack_sip
Date: Fri, 14 May 2010 21:33:38 +0200 (CEST)
Message-ID: <alpine.LSU.2.01.1005142133001.16437@obet.zrqbmnf.qr>
References: <20100514180138.GF15969@obsidianresearch.com> <4BED92AF.50704@trash.net> <20100514182601.GJ15969@obsidianresearch.com> <4BED99A3.2050404@trash.net> <4BEDA3CA.4030407@trash.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from borg.medozas.de ([188.40.89.202]:46696 "EHLO borg.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932242Ab0ENTdk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 May 2010 15:33:40 -0400
In-Reply-To: <4BEDA3CA.4030407@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Friday 2010-05-14 21:26, Patrick McHardy wrote:
>>> Should this be NF_DROP? As I understand it skb_linearize only failes
>>> if it runs out of memory, which probably means dropping is OK. But
>>> passing a packet that might need rewriting could be harmful..
>> 
>> We so far also didn't rewrite the packet. But agreed, its
>> a corner case and dropping it is the safer choice.
>
>This is what I've added to my tree. Tested with asterisk and TSO
>enabled NIC, which fails without this patch.
>

[..patch..]

Shouldn't we do this for the other nf_conntrack_xyz too?
That would mean getting rid of the size-limited locked packet
buffer.
