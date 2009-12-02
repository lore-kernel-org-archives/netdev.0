From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sch_htb: ix the deficit overflows
Date: Wed, 02 Dec 2009 01:20:17 -0800 (PST)
Message-ID: <20091202.012017.39623676.davem@davemloft.net>
References: <20091128000401.GA3713@ami.dom.local>
	<412e6f7f0911292026w704a70b8yc3af2c2473e05d34@mail.gmail.com>
	<20091130111020.GA7114@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiaosuo@gmail.com, hadi@cyberus.ca, netdev@vger.kernel.org,
	martin.devera@cdi.cz
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53343
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751605AbZLBJUL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2009 04:20:11 -0500
In-Reply-To: <20091130111020.GA7114@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Mon, 30 Nov 2009 11:10:20 +0000

> On Mon, Nov 30, 2009 at 12:26:33PM +0800, Changli Gao wrote:
>> And
>> if we use IMQ to shape traffic, the skb will be defragmented by
>> conntrack, and its size will be larger than MTU.
> 
> IMQ is a very nice thing, but it's considered broken as well, so it
> can't be the reason for changing HTB.

If you don't like IMQ, fine.  Simply consider TSO and GSO as another
set of mechanisms that can introduce this condition.

Because we toss large SKBs all over the strack quite freely,
protections like those suggested by Changli make perfect sense.

We really don't have an MTU for packets within our stack any more.
The code, by default, need to be able to handle anything.
