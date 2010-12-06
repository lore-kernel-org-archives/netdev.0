From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] use total_highpages when calculating lowmem-only
 allocation sizes (dccp)
Date: Mon, 06 Dec 2010 09:36:30 -0800 (PST)
Message-ID: <20101206.093630.104060994.davem@davemloft.net>
References: <4CFD2096020000780002627B@vpn.id2.novell.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org
To: JBeulich@novell.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47734
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752869Ab0LFRgD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Dec 2010 12:36:03 -0500
In-Reply-To: <4CFD2096020000780002627B@vpn.id2.novell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Jan Beulich" <JBeulich@novell.com>
Date: Mon, 06 Dec 2010 16:42:46 +0000

> For those (large) table allocations that come only from lowmem, the
> total amount of memory shouldn't really matter.
> 
> Signed-off-by: Jan Beulich <jbeulich@novell.com>

Instead of continually tweaking the bits in these code paths,
we should be converting them over to using a central routine
such as alloc_large_system_hash() where the logic is consolidated
_AND_ the code knows to use vmalloc() and NUMA aware allocations
when warranted.
