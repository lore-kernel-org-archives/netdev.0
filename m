From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Re: [PATCH V2] netfilter: h323: avoid potential attack
Date: Thu, 28 Jan 2016 06:07:43 -0800
Message-ID: <1453990063.7627.34.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1453971597-4811-1-git-send-email-zhouzhouyi@gmail.com>
	 <1453985821.7627.17.camel@edumazet-glaptop2.roam.corp.google.com>
	 <a703ec.53db.152885f2292.Coremail.yizhouzhou@ict.ac.cn>
	 <1453989650.7627.30.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Zhouyi Zhou <zhouzhouyi@gmail.com>, pablo@netfilter.org,
	kaber@trash.net, kadlec@blackhole.kfki.hu, davem@davemloft.net,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Zhouyi Zhou <yizhouzhou@ict.ac.cn>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:36148 "EHLO
	mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933171AbcA1OHp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jan 2016 09:07:45 -0500
In-Reply-To: <1453989650.7627.30.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-01-28 at 06:00 -0800, Eric Dumazet wrote:
> On Thu, 2016-01-28 at 21:14 +0800, Zhouyi Zhou wrote:
> 
> > My patch is intend to prevent kernel panic, to prevent reading garbage
> > or read data from a prior frame and leak secrets, the prototypes of the 
> > get_h2x5_addr functions and the functions that call get_h2x5_addr should
> > be changed, should we do this? 
> 
> In term of security, panics are better than allowing attacker to read
> data from other people, like a password.
> 
> BTW, are you able to trigger any panic ?
> 
> I am not familiar with this code, it is not obvious.
> 
> If a fix is needed, better doing it right.
> 


BTW, this module is protected by a lock (nf_h323_lock)

So adding a variable like 'h323_buffer_valid_bytes' that would contain
the number of valid bytes would not require to change prototypes.

This variable would be written when skb_header_pointer() is used in
get_tpkt_data() / get_udp_data()
