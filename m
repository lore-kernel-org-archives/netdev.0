From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC] iproute2, ifindex option
Date: Wed, 20 Jul 2011 08:37:53 -0700
Message-ID: <20110720083753.2b8de970@nehalam.ftrdhcpuser.net>
References: <f91760b4ff170e4bdbd46f40822dd95e@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:56850 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751695Ab1GTPh6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jul 2011 11:37:58 -0400
In-Reply-To: <f91760b4ff170e4bdbd46f40822dd95e@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 18 Jul 2011 11:38:33 +0300
Denys Fedoryshchenko <denys@visp.net.lb> wrote:

>  After battling with iproute2 interface name caching, i decided to try 
>  to introduce ifindex option, where i can specify manually device index, 
>  and avoid expensive device index lookups, especially during massive 
>  changes for qdisc/class.
>  In batch mode ll_map cache will cause problems on servers with ppp 
>  interfaces (same name after while can have another index), and also if i 
>  run command too often, each start it will retrieve list of all 
>  interfaces, on 3k+ interfaces it will be CPU hog.
> 
>  This is sample of patch, just for qdisc/class/filter modify and show 
>  operation.
> 
>  Here is some changes in logic, because before qdisc code during _list 
>  operation was not checking duplicate "dev" argument, as it done in 
>  _modify code and class/filter list code.
> 
>  Also maybe i need to change duparg to something else? Because:
>  centaur iproute2-newifindex # tc/tc -s -d filter show ifindex 23 dev 
>  sdf
>  Error: duplicate "ifindex": "sdf" is the second value.
>  Or it is ok like this?
> 
>  I'm sorry that patch is not inline, seems my webmail can't do it now, i 
>  will try to install normal mail client.

If caching is a problem, I would rather just get rid of the cache altogether.
There are a number of other places where it is a problem as well.
