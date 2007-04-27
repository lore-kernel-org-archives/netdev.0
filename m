From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] AF_RXRPC/AFS: Arch-specific fixes
Date: Fri, 27 Apr 2007 15:30:52 -0700 (PDT)
Message-ID: <20070427.153052.130847127.davem@davemloft.net>
References: <20070427143135.23545.43386.stgit@warthog.cambridge.redhat.com>
	<20070427143140.23545.37397.stgit@warthog.cambridge.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dhowells@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47451
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753148AbXD0Wan (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Apr 2007 18:30:43 -0400
In-Reply-To: <20070427143140.23545.37397.stgit@warthog.cambridge.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Howells <dhowells@redhat.com>
Date: Fri, 27 Apr 2007 15:31:40 +0100

> Fixes for various arch compilation problems:
> 
>  (*) Missing module exports.
> 
>  (*) Variable name collision when rxkad and af_rxrpc both built in
>      (rxrpc_debug).
> 
>  (*) Large constant representation problem (AFS_UUID_TO_UNIX_TIME).
> 
>  (*) Configuration dependencies.
> 
>  (*) printk() format warnings.
> 
> Signed-Off-By: David Howells <dhowells@redhat.com>

Applied to fix the build failures, but you have to do some
of this better, for example:

> diff --git a/net/rxrpc/rxkad.c b/net/rxrpc/rxkad.c
> index 1eaf529..5ec7051 100644
> --- a/net/rxrpc/rxkad.c
> +++ b/net/rxrpc/rxkad.c
> @@ -18,6 +18,7 @@
>  #include <linux/ctype.h>
>  #include <net/sock.h>
>  #include <net/af_rxrpc.h>
> +#define rxrpc_debug rxkad_debug
>  #include "ar-internal.h"

Please stop with this CPP macro stuff, it's really crap'ifying
your otherwise quite nice code.

Just use rxkad_debug in all the uses, splitting out things
properly.

THanks.
