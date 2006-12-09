From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] 2.6 driver for Silan SC92031 (second try)
Date: Fri, 8 Dec 2006 22:01:14 -0800
Message-ID: <20061208220114.b531bee0.akpm@osdl.org>
References: <4579C842.5000809@cesarb.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jeff Garzik <jgarzik@pobox.com>,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:48304 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759117AbWLIGB2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Dec 2006 01:01:28 -0500
To: Cesar Eduardo Barros <cesarb@cesarb.net>
In-Reply-To: <4579C842.5000809@cesarb.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 08 Dec 2006 18:17:06 -0200
Cesar Eduardo Barros <cesarb@cesarb.net> wrote:

> From: Cesar Eduardo Barros <cesarb@cesarb.net>
> 
> This is a driver for the Silan SC92031/Rsltek 8139D NIC chip.
> 
> ...

> +config SC92031
> +	depends on NET_PCI && PCI && EXPERIMENTAL
> +	select CRC32
>
> ...
>
> +	} while(unlikely(cmpxchg(&priv->intr_status,

You'll have the arm maintainer after you with a pointy stick.

cmpxchg is only available on certain architectures.  It would be acceptable
to make this driver depend on X86 (or something).  Better to rewrite this
code so it doesn't use cmpxchg.
