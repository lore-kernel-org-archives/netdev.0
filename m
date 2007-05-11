From: jamal <hadi@cyberus.ca>
Subject: RE: take 2 WAS (RE: [RFC] make qdisc_restart more readable
Date: Fri, 11 May 2007 18:43:12 -0400
Message-ID: <1178923392.4089.4.camel@localhost>
References: <D5C1322C3E673F459512FB59E0DDC32902D4280E@orsmsx414.amr.corp.intel.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.236]:45981 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751821AbXEKWnQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 May 2007 18:43:16 -0400
Received: by wx-out-0506.google.com with SMTP id h31so1014141wxd
        for <netdev@vger.kernel.org>; Fri, 11 May 2007 15:43:15 -0700 (PDT)
In-Reply-To: <D5C1322C3E673F459512FB59E0DDC32902D4280E@orsmsx414.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2007-11-05 at 15:01 -0700, Waskiewicz Jr, Peter P wrote:

> The current requeue calls in qdisc_restart() returns a value of 1 to the
> upper layer. 

Which was not meaningful ;->
i.e qdisc run would break as a result.
Note, this is still in conformance with net-2.6 based on a change in the
last few days made by Herbert - I was following his lead.
I put that comment there just as something to remember and
maybe revisit later.

>  If you return 0, the __qdisc_run() won't break from the
> while() it seems if you have to successfully requeue a packet.
> 

It wont; the check is for < 0

> 
> -static inline int qdisc_restart(struct net_device *dev)
> +int
> +qdisc_restart(struct net_device *dev)
>  {
> 
> Why is this no longer defined static?
> 

Good catch - i will restore it to what it was originally.

> 
> +	/* we need to refresh q because it may be invalid since we
> droped 
> 
> <nitpick>
> droped = dropped
> </nitpick>
> 

Ok, better to fix it now before the spelling police show up ;->

> That's all I have for now.  I'll try applying it for kicks and see what
> happens.

Just make those two fixes in your version; also note, you need Davems
net-2.6 tree.

cheers,
jamal

