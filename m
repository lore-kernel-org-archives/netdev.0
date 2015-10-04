From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH net] netfilter: remove the nh_scope test in
 rpfilter_lookup_reverse of ipt_rpfilter
Date: Sun, 4 Oct 2015 23:48:02 +0200
Message-ID: <20151004214802.GB6032@breakpoint.cc>
References: <c7a265fa26e9558115abb58869caa6012924355b.1443970560.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: network dev <netdev@vger.kernel.org>, fw@strlen.de
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:53589 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751800AbbJDVsF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Oct 2015 17:48:05 -0400
Content-Disposition: inline
In-Reply-To: <c7a265fa26e9558115abb58869caa6012924355b.1443970560.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Xin Long <lucien.xin@gmail.com> wrote:
> it seems the test is bogus and can be removed to fix this issue.
> 
> 	if (dev_match || flags & XT_RPFILTER_LOOSE)
> 		return FIB_RES_NH(res).nh_scope <= RT_SCOPE_HOST;
> 
> ipv6 does not have this issue.

netfilter patches should be sent to netfilter-devel@vger.kernel.org

>  #endif
> -	if (dev_match || flags & XT_RPFILTER_LOOSE)
> -		return FIB_RES_NH(res).nh_scope <= RT_SCOPE_HOST;
>  	return dev_match;
>  }

This breaks --loose option, no?

Thats why I earlier suggested to change this to

> -	if (dev_match || flags & XT_RPFILTER_LOOSE)
> -		return FIB_RES_NH(res).nh_scope <= RT_SCOPE_HOST;
+	return dev_match || flags & XT_RPFILTER_LOOSE;
