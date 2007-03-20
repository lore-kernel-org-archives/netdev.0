From: Patrick McHardy <kaber@trash.net>
Subject: Re: Oops in filter add
Date: Tue, 20 Mar 2007 12:02:15 +0100
Message-ID: <45FFBF37.4030801@trash.net>
References: <45FEEE35.6090606@reflexsecurity.com>	 <20070319.192206.21926062.davem@davemloft.net>	 <1174373645.4895.15.camel@localhost>  <45FF8602.8040108@trash.net>	 <1174375109.4895.22.camel@localhost>  <45FF8D6A.4010308@trash.net> <1174382739.4864.11.camel@localhost> <45FFBD7F.4010005@reflexsecurity.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org, tgraf@suug.ch
To: Chris Madden <chris@reflexsecurity.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:46733 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751196AbXCTLCW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Mar 2007 07:02:22 -0400
In-Reply-To: <45FFBD7F.4010005@reflexsecurity.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Chris Madden wrote:
> Thanks for all your replies!
> 
> One thing I did notice in examining tc_ctl_tfilter was that there is
> something like:
> 
>         qdisc_lock_tree(dev);
>         tp->next = *back;
>         *back = tp;
>         qdisc_unlock_tree(dev);
> 
> And then proceed to the data structure down below with:
> 
> err = tp->ops->change(tp, cl, t->tcm_handle, tca, &fh);
> 
> Simply reordering these seems to ameliorate the problem greatly.  I
> don't know if this is a generic solution or something specific to the
> basic filter only. 


It might hide the problem, but there are currently a lot of places
where things can go wrong.

