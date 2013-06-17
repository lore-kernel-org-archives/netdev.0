From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 00/16] tipc: make use of kernel threads to
 simplify things
Date: Mon, 17 Jun 2013 15:53:51 -0700 (PDT)
Message-ID: <20130617.155351.912153627551806035.davem@davemloft.net>
References: <1371480891-5264-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jon.maloy@ericsson.com,
	ying.xue@windriver.com, erik.hugne@ericsson.com,
	nhorman@tuxdriver.com
To: paul.gortmaker@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39984 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751361Ab3FQWxw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Jun 2013 18:53:52 -0400
In-Reply-To: <1371480891-5264-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Mon, 17 Jun 2013 10:54:35 -0400

> This is a rework of the content sent earlier[1], with the following changes:
> 
> 	-drop the Kconfig --> modparam conversion patch; this was
> 	 requested to be replaced[2] with a dynamic port quantity resizing.
> 	 Ying and Erik were discussing how best to achieve this, and then
> 	 vacation schedules got in the way, so implementing that will
> 	 come (hopefully) in the next round.
> 
> 	-rework the sk_rcvbuf patch to allow memory resizing via sysctl
> 	 as per what Ying and Neil discussed[3]
> 
> 	-add 4 more seemingly straigtforward and relatively small changes
> 	 from Ying (the last 4 in the series).
> 
> 	-add cosmetic UAPI comment update patch from Ying.
> 
> That said, the largest change is still the one where we make use of
> the fact that linux supports kernel threads and do the server like
> operations within kernel threads.  As Jon says:  
> 
>    We remove the last remnants of the TIPC native API, to make it
>    possible to simplify locking policy and solve a problem with lost
>    topology events.
>  
>    First, we introduce a socket-based alternative to the native API.
> 
>    Second, we convert the two remaining users of the native API, the 
>    TIPC internal topology server and the configuarion server, to use the
>    new API. 
> 
>    Third, we remove the remaining code pertaining to the native API.
> 
> I have re-tested this collection of commits between 32 and 64 bit x86
> machines using the standard tipc test suite, and build tested for ppc.

Series applied, thanks Paul.
