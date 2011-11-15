From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: re: IPv6 routing, NLM_F_* flag support: REPLACE and EXCL
Date: Tue, 15 Nov 2011 12:01:07 +0300
Message-ID: <20111115090107.GA18307@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: matti.vaittinen@nsn.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet15.oracle.com ([141.146.126.227]:23989 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753566Ab1KOJBV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2011 04:01:21 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

flags support, warn about missing CREATE flag

Hello Matti Vaittinen,

This is a semi-automatic email about new static checker warnings.

The patch 4a287eba2de3: "IPv6 routing, NLM_F_* flag support: REPLACE 
and EXCL flags support, warn about missing CREATE flag" from Nov 14, 
2011, leads to the following Smatch complaint:

net/ipv6/ip6_fib.c +656 fib6_add_rt2node()
	 error: we previously assumed 'info' could be null (see line 641)

net/ipv6/ip6_fib.c
   640		    (info->nlh->nlmsg_flags&NLM_F_REPLACE));
   641		int add = ((NULL == info || NULL == info->nlh) ||
                            ^^^^^^^^^^^^
Checked here.

   642		    (info->nlh->nlmsg_flags&NLM_F_CREATE));
   643		int found = 0;
   644	
   645		ins = &fn->leaf;
   646	
   647		for (iter = fn->leaf; iter; iter=iter->dst.rt6_next) {
   648			/*
   649			 *	Search for duplicates
   650			 */
   651	
   652			if (iter->rt6i_metric == rt->rt6i_metric) {
   653				/*
   654				 *	Same priority level
   655				 */
   656				if (NULL != info->nlh &&
                                            ^^^^^^^^^
Not checked here.  Btw, I looked at the callers and info is always
a valid pointer.

   657				    (info->nlh->nlmsg_flags&NLM_F_EXCL))
   658					return -EEXIST;

regards,
dan carpenter
