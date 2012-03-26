From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: reference the ipv4 sysctl table header
Date: Mon, 26 Mar 2012 18:24:11 -0400 (EDT)
Message-ID: <20120326.182411.41401140080225401.davem@davemloft.net>
References: <20120326222359.GB28123@dztty>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, viro@zeniv.linux.org.uk,
	netdev@vger.kernel.org
To: tixxdz@opendz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:35357 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757470Ab2CZWYQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Mar 2012 18:24:16 -0400
In-Reply-To: <20120326222359.GB28123@dztty>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Djalal Harouni <tixxdz@opendz.org>
Date: Mon, 26 Mar 2012 23:23:59 +0100

> +static struct ctl_table_header *ip4_base;
> +
>  /*
>   * We really need to sanitize the damn ipv4 init order, then all
>   * this nonsense will go away.
>   */
> -void __init ip_static_sysctl_init(void)
> +int __init ip_static_sysctl_init(void)
>  {
> -	register_sysctl_paths(ipv4_path, ipv4_skeleton);
> +	ip4_base = register_sysctl_paths(ipv4_path, ipv4_skeleton);

This is so incredibly stupid, just panic() or similar if this
returns NULL.

And find another way to annotate this for memleak so we don't need to
waste an entire pointer, which is never used, in the data section.
