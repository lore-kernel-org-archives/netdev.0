From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] Fix race in ipv6_flowlabel_opt() when inserting
 two labels
Date: Thu, 18 Oct 2007 05:19:19 -0700 (PDT)
Message-ID: <20071018.051919.07619008.davem@davemloft.net>
References: <47174A92.4090701@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33185
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755686AbXJRMTF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2007 08:19:05 -0400
In-Reply-To: <47174A92.4090701@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Emelyanov <xemul@openvz.org>
Date: Thu, 18 Oct 2007 15:59:14 +0400

> In the IPV6_FL_A_GET case the hash is checked for flowlabels
> with the given label. If it is not found, the lock, protecting 
> the hash, is dropped to be re-get for writing. After this a
> newly allocated entry is inserted, but no checks are performed
> to catch a classical SMP race, when the conflicting label may 
> be inserted on another cpu.
> 
> Use the (currently unused) return value from fl_intern() to
> return the conflicting entry (if found) and re-check, whether
> we can reuse it (IPV6_FL_F_EXCL) or return -EEXISTS.
> 
> Also add the comment, about why not re-lookup the current
> sock for conflicting flowlabel entry.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied.
