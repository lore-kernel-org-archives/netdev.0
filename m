From: jamal <hadi@cyberus.ca>
Subject: Re: Oops in filter add
Date: Tue, 20 Mar 2007 02:54:05 -0400
Message-ID: <1174373645.4895.15.camel@localhost>
References: <45FEEE35.6090606@reflexsecurity.com>
	 <20070319.192206.21926062.davem@davemloft.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: chris@reflexsecurity.com, netdev@vger.kernel.org, tgraf@suug.ch
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.231]:17138 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751452AbXCTGyK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Mar 2007 02:54:10 -0400
Received: by wx-out-0506.google.com with SMTP id h31so1593020wxd
        for <netdev@vger.kernel.org>; Mon, 19 Mar 2007 23:54:09 -0700 (PDT)
In-Reply-To: <20070319.192206.21926062.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2007-19-03 at 19:22 -0700, David Miller wrote:

> 
> I think this should use dev->queue_lock.
> 

It would slow down things if he is doing both ingress and egress
traffic as well as control changes.

> It looks like the idea might have been to allow more parallelized
> running of ingress filters, but this is done wrong and leads to
> the crashes you are seeing.

The main idea is to avoid one BigLock for both ingress and egress;
Which was/is still useful in the compat mode where netfilter is used
instead. 

> Can you just replace the above with dev->queue_lock and see if
> that makes your problem go away?  THanks.

It should; 
i will stare at the code later and see if i can send a better patch,
maybe a read_lock(qdisc_tree_lock). Chris, if you can experiment by just
locking against filters instead, that would be nicer for the reasons i
described above.

cheers,
jamal

