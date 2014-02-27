From: Amir Vadai <amirv@mellanox.com>
Subject: Re: net/mlx4_en: Pad ethernet packets smaller than 17 bytes
Date: Thu, 27 Feb 2014 23:47:54 +0200
Message-ID: <20140227214752.GA2678@mtl-eit-vdi-22.mtl.labs.mlnx>
References: <20140227140203.GA13112@mtl-eit-vdi-22.mtl.labs.mlnx>
 <1393512255.26794.20.camel@edumazet-glaptop2.roam.corp.google.com>
 <20140227154635.GA24226@mtl-eit-vdi-22.mtl.labs.mlnx>
 <20140227.153601.1100017228027738567.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, David.Laight@ACULAB.COM,
	netdev@vger.kernel.org, yevgenyp@mellanox.com,
	ogerlitz@mellanox.com, eugenia@mellanox.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:44295 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752701AbaB0Vr6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Feb 2014 16:47:58 -0500
Received: by mail-wi0-f169.google.com with SMTP id bs8so1179026wib.2
        for <netdev@vger.kernel.org>; Thu, 27 Feb 2014 13:47:57 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20140227.153601.1100017228027738567.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 27/02/14 15:36 -0500, David Miller wrote:
> From: Amir Vadai <amirv@mellanox.com>
> Date: Thu, 27 Feb 2014 17:46:37 +0200
> 
> > On 27/02/14 06:44 -0800, Eric Dumazet wrote:
> >> On Thu, 2014-02-27 at 16:02 +0200, Amir Vadai wrote:
> >> >  
> >> > Yes, skb will not be classified as inline-able if nr_frags != 1.
> >> > See is_inline()
> > 
> > Maybe I wasn't accurate enough. inline-able skb must have:
> > 1. skb->len < inline_thold 
> > 2. nr_frags <= 1
> > 
> > Default value for inline_thold is 104 and it is a module parameter
> > that can be changed.
> 
> BTW, the canonical way to deal with minimum length requirements is to
> use skb_padto().

I think that in this case it will be a bit of an overshoot. It
will add many unnecessary operations because it need to make sure that
there is enough space in the skb linear buffer for the padding. And in
my case the restriction is on the hardware buffer, so IMHO there is no
need to manipulate the skb.

Amir
