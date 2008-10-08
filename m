From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [PATCH] add a sysctl to disable TCP simultaneous connection
 opening
Date: Wed, 8 Oct 2008 08:50:34 -0700
Message-ID: <20081008085034.910551dc.randy.dunlap@oracle.com>
References: <20081008081109.GA25342@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:18462 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753941AbYJHPv2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2008 11:51:28 -0400
In-Reply-To: <20081008081109.GA25342@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 8 Oct 2008 10:11:09 +0200 Willy Tarreau wrote:

>  Documentation/networking/ip-sysctl.txt |   22 ++++++++++++++++++++++
> 
> diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
> index d849326..cefc894 100644
> --- a/Documentation/networking/ip-sysctl.txt
> +++ b/Documentation/networking/ip-sysctl.txt
> @@ -101,6 +101,28 @@ inet_peer_gc_maxtime - INTEGER
>  
>  TCP variables: 
>  
> +tcp_simult_connect - BOOLEAN
> +	Enables TCP simultaneous connect feature conforming to RFC793.
> +	Strict implementation of RFC793 (TCP) requires support for a feature
> +	called "simultaneous connect", which allows two clients to connect to
> +	each other without anyone entering a listening state.  While almost
> +	never used, and supported by few OSes, Linux supports this feature.
> +
> +	However, it introduces a weakness in the protocol which makes it very
> +	easy for an attacker to prevent a client from connecting to a known
> +	server. The attacker only has to guess the source port to shut down
> +	the client connection during its establishment. The impact is limited,
> +	but it may be used to prevent an antivirus or IPS from fetching updates
> +	and not detecting an attack, or to prevent an SSL gateway from fetching
> +	a CRL for example.
> +
> +	If you want absolute compatibility with any possible application,
> +	you should set it to 1. If you prefer to enhance security on your
> +	systems you'd better let it to 0. After four years of usage on

	                     set it to 0.
or did you mean: (?)
	                     let it be 0.

> +	hundreds of systems, no application was ever found to require this
> +	feature, which is not even supported by most firewalls.
> +	Default: 0
> +
>  somaxconn - INTEGER
>  	Limit of socket listen() backlog, known in userspace as SOMAXCONN.
>  	Defaults to 128.  See also tcp_max_syn_backlog for additional tuning


---
~Randy
