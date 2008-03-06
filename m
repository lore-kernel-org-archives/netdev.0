From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] Make /proc/net a symlink on /proc/self/net (v2)
Date: Thu, 6 Mar 2008 07:24:40 -0500
Message-ID: <20080306122440.GA28561@infradead.org>
References: <47CFB6CA.8090001@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:34418 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753939AbYCFMYs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2008 07:24:48 -0500
Content-Disposition: inline
In-Reply-To: <47CFB6CA.8090001@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 06, 2008 at 12:18:02PM +0300, Pavel Emelyanov wrote:
> Current /proc/net is done with so called "shadows", but current
> implementation is broken and has little chances to get fixed.
> 
> The problem is that dentries subtree of /proc/net directory has
> fancy revalidation rules to make processes living in different
> net namespaces see different entries in /proc/net subtree, but
> currently, tasks see in the /proc/net subdir the contents of any
> other namespace, depending on who opened the file first.
> 
> The proposed fix is to turn /proc/net into a symlink, which points
> to /proc/self/net, which in turn shows what previously was in
> /proc/net - the network-related info, from the net namespace the
> appropriate task lives in.

Yes, that's a much better way to get this functionality.

