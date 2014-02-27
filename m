From: Amir Vadai <amirv@mellanox.com>
Subject: Re: net/mlx4_en: Pad ethernet packets smaller than 17 bytes
Date: Thu, 27 Feb 2014 17:46:37 +0200
Message-ID: <20140227154635.GA24226@mtl-eit-vdi-22.mtl.labs.mlnx>
References: <1393504026-13384-1-git-send-email-amirv@mellanox.com>
 <1393504026-13384-4-git-send-email-amirv@mellanox.com>
 <063D6719AE5E284EB5DD2968C1650D6D0F6CCB7E@AcuExch.aculab.com>
 <20140227140203.GA13112@mtl-eit-vdi-22.mtl.labs.mlnx>
 <1393512255.26794.20.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Laight <David.Laight@ACULAB.COM>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eugenia Emantayev <eugenia@mellanox.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:58443 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752044AbaB0Pqm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Feb 2014 10:46:42 -0500
Received: by mail-wi0-f172.google.com with SMTP id r20so844882wiv.17
        for <netdev@vger.kernel.org>; Thu, 27 Feb 2014 07:46:41 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1393512255.26794.20.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 27/02/14 06:44 -0800, Eric Dumazet wrote:
> On Thu, 2014-02-27 at 16:02 +0200, Amir Vadai wrote:
> >  
> > Yes, skb will not be classified as inline-able if nr_frags != 1.
> > See is_inline()

Maybe I wasn't accurate enough. inline-able skb must have:
1. skb->len < inline_thold 
2. nr_frags <= 1

Default value for inline_thold is 104 and it is a module parameter
that can be changed.

> 
> How often this inline stuff ever happens ?
> 
> It looks like the length of the frame needs to be shorter than 44 bytes,
> right ?
It should be shorter than 104 - inline_thold default (and max) value is 104.
I don't understand why you say 44.

> 
> Minimal length for TCP is 54 bytes.
> 
> I wonder why you tried to inline stuff that is probably never
> seen in real workload.
> 

If you mean why did I try to send packets shorter than 17 using inline
- the answer is that it is easy to do it, so why not to?

Amir
