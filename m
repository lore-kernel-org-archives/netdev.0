From: Eric Paris <eparis@parisplace.org>
Subject: Re: [PATCH 10/13] NetLabel: use cipso_v4_doi_search() for local
	CIPSOv4 functions
Date: Thu, 23 Nov 2006 20:24:34 -0500
Message-ID: <1164331474.2079.39.camel@localhost.localdomain>
References: <20061117223842.399078000@hp.com>
	 <20061117224336.711076000@hp.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov, jmorris@namei.org,
	Alexander Viro <aviro@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:22936 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S1757549AbWKXBgr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Nov 2006 20:36:47 -0500
To: paul.moore@hp.com
In-Reply-To: <20061117224336.711076000@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-11-17 at 17:38 -0500, paul.moore@hp.com wrote:

> Index: net-2.6.20_netlabel-base-work/net/ipv4/cipso_ipv4.c
> ===================================================================
> --- net-2.6.20_netlabel-base-work.orig/net/ipv4/cipso_ipv4.c
> +++ net-2.6.20_netlabel-base-work/net/ipv4/cipso_ipv4.c
> @@ -1136,7 +1136,7 @@ int cipso_v4_validate(unsigned char **op
>  	}
>  
>  	rcu_read_lock();
> -	doi_def = cipso_v4_doi_getdef(ntohl(*((__be32 *)&opt[2])));
> +	doi_def = cipso_v4_doi_search(ntohl(*((u32 *)&opt[2])));
>  	if (doi_def == NULL) {
>  		err_offset = 2;
>  		goto validate_return_locked;


This appears to reverse the previous endian work by Al Viro, was this
intended?

http://www.kernel.org/git/?p=linux/kernel/git/davem/net-2.6.20.git;a=commitdiff;h=8d7d47b647d7bc05443f1a8a5012e6b41be1c827

-Eric

