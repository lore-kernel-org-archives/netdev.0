From: Thomas Graf <tgraf@infradead.org>
Subject: Re: tc match MAC destination
Date: Wed, 15 Jun 2011 09:23:06 -0400
Message-ID: <20110615132306.GA919@canuck.infradead.org>
References: <1308125523.30324.64.camel@ierdnac-hp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pdoru.kernel@evox.ro, netdev@vger.kernel.org
To: Andrei Popa <ierdnah@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:33325 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753337Ab1FONXM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jun 2011 09:23:12 -0400
Content-Disposition: inline
In-Reply-To: <1308125523.30324.64.camel@ierdnac-hp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 15, 2011 at 11:12:01AM +0300, Andrei Popa wrote:
> I want to shape PVSTP+ traffic (traffic that has MAC destination
> 01:00:0c:cc:cc:cd) and it doesn't work.
> I've tried
> filter parent 1: protocol 802_3 pref 2 u32 fh 802::11 order 17 key ht
> 802 bkt 0 flowid 1:3 
>   match 01000ccc/ffffffff at 0
> but it doesn't work.

u32 offset 0 corresponds to the network layer and thus will
match the first byte of the ip layer or whatever protocol
is found on that layer.

You can use the cmp ematch to match on the mac layer:

Use something like this:
filter add basic match 'cmp(0x01000ccc at 0 layer link mask 0xffffffff)'

... cmp(>>help<<)...
Usage: cmp(ALIGN at OFFSET [ ATTRS ] { eq | lt | gt } VALUE)
where: ALIGN  := { u8 | u16 | u32 }
       ATTRS  := [ layer LAYER ] [ mask MASK ] [ trans ]
       LAYER  := { link | network | transport | 0..2 }

Example: cmp(u16 at 3 layer 2 mask 0xff00 gt 20

