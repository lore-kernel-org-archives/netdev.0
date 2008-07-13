From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] Fix warnings on calls to P54P_READ() for which the
 result is discarded
Date: Sat, 12 Jul 2008 22:24:46 -0700
Message-ID: <20080712222446.552f4069.akpm@linux-foundation.org>
References: <20080711141443.14665.63279.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: flamingice@sourmilk.net, linville@tuxdriver.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Howells <dhowells@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:46033 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750812AbYGMFZ5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Jul 2008 01:25:57 -0400
In-Reply-To: <20080711141443.14665.63279.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 11 Jul 2008 15:14:43 +0100 David Howells <dhowells@redhat.com> wrote:

> Fix warnings on calls to P54P_READ() for which the result is discarded because
> the side-effect of accessing hardware is what's of interest, not the result of
> performing the read.
> 
> The warnings are of the form:
> 
> drivers/net/wireless/p54/p54pci.c:55: warning: value computed is not used

hm, why aren't I seeing these?

> Casting to (void) gets rid of this.

This makes the ugly uglier.  Would it fix the warnings if we were to do

-#define P54P_READ(r) (__force __le32)__raw_readl(&priv->map->r)
+static inline __le32 p54p_read(__le32 *addr)
+{
+	return (__force __le32)__raw_readl(addr);
+}

...
-	P54P_READ(dev_int);
+	P54P_READ(&priv->map->dev_int);

or something along those lines?

Because the cpp trickery in there really isn't very nice.
