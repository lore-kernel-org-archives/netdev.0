From: Matti Vaittinen <matti.vaittinen@nsn.com>
Subject: re: IPv6 routing, NLM_F_* flag support: REPLACE and EXCL
Date: Tue, 15 Nov 2011 12:26:23 +0200
Message-ID: <1321352783.1858.62.camel@hakki>
References: <20111115090107.GA18307@elgon.mountain>
Reply-To: matti.vaittinen@nsn.com
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org
To: ext Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from demumfd001.nsn-inter.net ([93.183.12.32]:10271 "EHLO
	demumfd001.nsn-inter.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753959Ab1KOKPB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2011 05:15:01 -0500
In-Reply-To: <20111115090107.GA18307@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-11-15 at 12:01 +0300, ext Dan Carpenter wrote:
> flags support, warn about missing CREATE flag
> 
> Hello Matti Vaittinen,
> 
> This is a semi-automatic email about new static checker warnings.
> 
> The patch 4a287eba2de3: "IPv6 routing, NLM_F_* flag support: REPLACE 
> and EXCL flags support, warn about missing CREATE flag" from Nov 14, 
> 2011, leads to the following Smatch complaint:
> 
> net/ipv6/ip6_fib.c +656 fib6_add_rt2node()
> 	 error: we previously assumed 'info' could be null (see line 641)
> 
> net/ipv6/ip6_fib.c
>    640		    (info->nlh->nlmsg_flags&NLM_F_REPLACE));
>    641		int add = ((NULL == info || NULL == info->nlh) ||
>                             ^^^^^^^^^^^^
> Checked here.
> 
>    642		    (info->nlh->nlmsg_flags&NLM_F_CREATE));

>    656				if (NULL != info->nlh &&
>                                             ^^^^^^^^^
> Not checked here.  Btw, I looked at the callers and info is always
> a valid pointer.

Yes. It really seems the info is always a valid pointer. 
I could find only two places where this info can come from.
First is ip6_ins_rt at route.c where info is allocated from stack. 
Second is ip6_route_add, where info is part of the 
fib6_config struct - and already assumed to be valid.


I'll prepare a patch which removes these unnecessary checks.




-- 
Matti Vaittinen
+358 504863070
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Told a UDP joke the other night...
...but I'm not sure everyone got it...
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
