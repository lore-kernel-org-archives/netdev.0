From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH 3/4] [Net] Support Xen accelerated network plugin
 modules
Date: Mon, 21 May 2007 10:52:58 -0700
Message-ID: <20070521105258.7988fd6e@freepuppy>
References: <1179494208.14376.10.camel@moonstone.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xensource.com, netdev@vger.kernel.org,
	muli@il.ibm.com, herbert@gondor.apana.org.au
To: Kieran Mansley <kmansley@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([207.189.120.12]:56900 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756450AbXEURy2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 May 2007 13:54:28 -0400
In-Reply-To: <1179494208.14376.10.camel@moonstone.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 18 May 2007 14:16:48 +0100
Kieran Mansley <kmansley@solarflare.com> wrote:

> Add support to Xen netfront for accelerated plugin module
> 
>
> 
> +/*
> + * List of all netfront accelerator plugin modules available.  Each
> + * list entry is of type struct netfront_accelerator.
> + */ 
> +static struct list_head accelerators_list;
> +/*
> + * Lock to protect access to accelerators_list, and also used to
> + * protect the hooks_usecount field in struct netfront_accelerator
> + * against concurrent access 
> + */
> +static spinlock_t accelerators_lock;
> +


Your locking model is more complex than it needs to be.
If you just used RCU for access, and depended on the existing RT netlink
mutex (a.k.a big network lock), for setup; then you wouldn't need to
do any of your own locking.

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
