From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: IP LRO
Date: Thu, 8 Jan 2009 12:17:56 +0300
Message-ID: <20090108091755.GA23458@ioremap.net>
References: <4965BF43.1060801@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, liranl@mellanox.co.il,
	tziporet@mellanox.co.il
To: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from genesysrack.ru ([195.178.208.66]:57595 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751068AbZAHJR6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Jan 2009 04:17:58 -0500
Content-Disposition: inline
In-Reply-To: <4965BF43.1060801@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Yevgeny.

On Thu, Jan 08, 2009 at 10:54:27AM +0200, Yevgeny Petrilin (yevgenyp@mellanox.co.il) wrote:
> We have recently implemented a reassembly of fragmented IP packets in
> mlx4_en driver. This offload gives a performance boost in case of incoming
> traffic with fragmented packets (such as UDP traffic with message size larger
> then MTU). The attached patch contains this offload. I believe that we can make
> this code generic, maybe part of inet_lro.
> Please review and comment.

Frankly from the patch it is quite hard to tell if it is suitable or not
for the generic usage. For example no structure access or lookup are
guarded with some locks, likely they are somewhere in the driver itself,
so at least it should be documented. Fragment structure can be
rearranged to better fit the alignment rules of the platform (there are
gaps even on 32bit). Please provide higher-level description on how it
operates compared to existing GRO/LRO (except that it is one layer lower),
how strcutres are operated, what are the lifetime rules for them and
appropriate skbs, what are the usage case. How will it live with
GRO/LRO, i.e. who will steal the skb if it matches both subsystems.

-- 
	Evgeniy Polyakov
