From: Patrick McHardy <kaber@trash.net>
Subject: Re: Oops in filter add
Date: Tue, 20 Mar 2007 07:58:10 +0100
Message-ID: <45FF8602.8040108@trash.net>
References: <45FEEE35.6090606@reflexsecurity.com>	 <20070319.192206.21926062.davem@davemloft.net> <1174373645.4895.15.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, chris@reflexsecurity.com,
	netdev@vger.kernel.org, tgraf@suug.ch
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:41963 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752811AbXCTG6N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Mar 2007 02:58:13 -0400
In-Reply-To: <1174373645.4895.15.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal wrote:
> On Mon, 2007-19-03 at 19:22 -0700, David Miller wrote:
> 
>>It looks like the idea might have been to allow more parallelized
>>running of ingress filters, but this is done wrong and leads to
>>the crashes you are seeing.
> 
> 
> The main idea is to avoid one BigLock for both ingress and egress;
> Which was/is still useful in the compat mode where netfilter is used
> instead. 


In that case is isn't even used.

>>Can you just replace the above with dev->queue_lock and see if
>>that makes your problem go away?  THanks.
> 
> 
> It should; 
> i will stare at the code later and see if i can send a better patch,
> maybe a read_lock(qdisc_tree_lock).


You would need to make qdisc_lock_tree() aware of the difference
between ingress and egress.
