From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Make /proc/net a symlink on /proc/self/net
Date: Sun, 23 Mar 2008 06:16:50 -0700 (PDT)
Message-ID: <20080323.061650.239772151.davem@davemloft.net>
References: <47CE8FF7.7000701@openvz.org>
	<200803231400.41397.vda.linux@googlemail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xemul@openvz.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	ebiederm@xmission.com, adobriyan@openvz.org
To: vda.linux@googlemail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60932
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756020AbYCWNQf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Mar 2008 09:16:35 -0400
In-Reply-To: <200803231400.41397.vda.linux@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Denys Vlasenko <vda.linux@googlemail.com>
Date: Sun, 23 Mar 2008 14:00:41 +0100

> On Wednesday 05 March 2008 13:20, Pavel Emelyanov wrote:
> > Current /proc/net is done with so called "shadows", but current
> > implementation is broken and has little chances to get fixed.
> > 
> > The problem is that dentries subtree of /proc/net directory has
> > fancy revalidation rules to make processes living in different
> > net namespaces see different entries in /proc/net subtree, but
> > currently, tasks see in the /proc/net subdir the contents of any
> > other namespace, depending on who opened the file first.
> > 
> > The proposed fix is to turn /proc/net into a symlink, which points
> > to /proc/self/net, which in turn shows what previously was in
> > /proc/net - the network-related info, from the net namespace the
> > appropriate task lives in.
> > 
> > # ls -l /proc/net
> > lrwxrwxrwx  1 root root 8 Mar  5 15:17 /proc/net -> self/net
> 
> This broke tools which read /proc/net/dev. Under non-root,
> they are no longer working. This is a regression.

This is fixed with a commit that was made yesterday.
