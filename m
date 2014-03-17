From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next] net: sched: use no more than one page in struct
 fw_head
Date: Mon, 17 Mar 2014 13:51:01 +0000
Message-ID: <20140317135101.GA8956@casper.infradead.org>
References: <1394744203.21721.53.camel@edumazet-glaptop2.roam.corp.google.com>
 <20140313211509.GP21124@linux.vnet.ibm.com>
 <53229704.1040808@gmail.com>
 <20140314132834.GS21124@linux.vnet.ibm.com>
 <1394804798.21721.64.camel@edumazet-glaptop2.roam.corp.google.com>
 <20140314153810.GX21124@linux.vnet.ibm.com>
 <20140314185005.GA17041@linux.vnet.ibm.com>
 <20140314185917.GA18933@linux.vnet.ibm.com>
 <1394826958.9668.4.camel@edumazet-glaptop2.roam.corp.google.com>
 <1394985990.9668.26.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	John Fastabend <john.fastabend@gmail.com>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:58439 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752989AbaCQNvE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Mar 2014 09:51:04 -0400
Content-Disposition: inline
In-Reply-To: <1394985990.9668.26.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/16/14 at 09:06am, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> In commit b4e9b520ca5d ("[NET_SCHED]: Add mask support to fwmark
> classifier") Patrick added an u32 field in fw_head, making it slightly
> bigger than one page.
> 
> Change the layout of this structure and let compiler emit a reciprocal
> divide for fw_hash(), as this makes the core more readable and
> more efficient those days.

I think you  need to educate me a bit on this. objdump
spits out the following:

static u32 fw_hash(u32 handle)
{
        return handle % HTSIZE;
  1d:   bf ff 01 00 00          mov    edi,0x1ff
  22:   89 f0                   mov    eax,esi
  24:   31 d2                   xor    edx,edx
  26:   f7 f7                   div    edi

Doesn't look like a reciprocal div to me. Where did I
screw up or why doesn't gcc optimize it properly?
